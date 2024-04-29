--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_PROGRAM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_PROGRAM_PVT_W" as
  /* $Header: pvxwprgb.pls 120.1 2008/03/10 05:56:30 hekkiral ship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy pv_partner_program_pvt.partner_program_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_100
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
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_DATE_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_DATE_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_NUMBER_TABLE
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_1600
    , a57 JTF_VARCHAR2_TABLE_1600
    , a58 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).program_id := a0(indx);
          t(ddindx).program_type_id := a1(indx);
          t(ddindx).custom_setup_id := a2(indx);
          t(ddindx).program_level_code := a3(indx);
          t(ddindx).program_parent_id := a4(indx);
          t(ddindx).program_owner_resource_id := a5(indx);
          t(ddindx).program_start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).program_end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).allow_enrl_until_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).citem_version_id := a9(indx);
          t(ddindx).membership_valid_period := a10(indx);
          t(ddindx).membership_period_unit := a11(indx);
          t(ddindx).process_rule_id := a12(indx);
          t(ddindx).prereq_process_rule_id := a13(indx);
          t(ddindx).program_status_code := a14(indx);
          t(ddindx).submit_child_nodes := a15(indx);
          t(ddindx).inventory_item_id := a16(indx);
          t(ddindx).inventory_item_org_id := a17(indx);
          t(ddindx).bus_user_resp_id := a18(indx);
          t(ddindx).admin_resp_id := a19(indx);
          t(ddindx).no_fee_flag := a20(indx);
          t(ddindx).vad_invite_allow_flag := a21(indx);
          t(ddindx).global_mmbr_reqd_flag := a22(indx);
          t(ddindx).waive_subsidiary_fee_flag := a23(indx);
          t(ddindx).qsnr_ttl_all_page_dsp_flag := a24(indx);
          t(ddindx).qsnr_hdr_all_page_dsp_flag := a25(indx);
          t(ddindx).qsnr_ftr_all_page_dsp_flag := a26(indx);
          t(ddindx).allow_enrl_wout_chklst_flag := a27(indx);
          t(ddindx).user_status_id := a28(indx);
          t(ddindx).enabled_flag := a29(indx);
          t(ddindx).attribute_category := a30(indx);
          t(ddindx).attribute1 := a31(indx);
          t(ddindx).attribute2 := a32(indx);
          t(ddindx).attribute3 := a33(indx);
          t(ddindx).attribute4 := a34(indx);
          t(ddindx).attribute5 := a35(indx);
          t(ddindx).attribute6 := a36(indx);
          t(ddindx).attribute7 := a37(indx);
          t(ddindx).attribute8 := a38(indx);
          t(ddindx).attribute9 := a39(indx);
          t(ddindx).attribute10 := a40(indx);
          t(ddindx).attribute11 := a41(indx);
          t(ddindx).attribute12 := a42(indx);
          t(ddindx).attribute13 := a43(indx);
          t(ddindx).attribute14 := a44(indx);
          t(ddindx).attribute15 := a45(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a46(indx));
          t(ddindx).last_updated_by := a47(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a48(indx));
          t(ddindx).created_by := a49(indx);
          t(ddindx).last_update_login := a50(indx);
          t(ddindx).object_version_number := a51(indx);
          t(ddindx).program_name := a52(indx);
          t(ddindx).program_description := a53(indx);
          t(ddindx).source_lang := a54(indx);
          t(ddindx).qsnr_title := a55(indx);
          t(ddindx).qsnr_header := a56(indx);
          t(ddindx).qsnr_footer := a57(indx);
          t(ddindx).membership_fees := a58(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_partner_program_pvt.partner_program_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_200
    , a46 out nocopy JTF_DATE_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_DATE_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_NUMBER_TABLE
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_VARCHAR2_TABLE_200
    , a56 out nocopy JTF_VARCHAR2_TABLE_1600
    , a57 out nocopy JTF_VARCHAR2_TABLE_1600
    , a58 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_100();
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
    a44 := JTF_VARCHAR2_TABLE_200();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_DATE_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_DATE_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_NUMBER_TABLE();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_300();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_1600();
    a57 := JTF_VARCHAR2_TABLE_1600();
    a58 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_100();
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
      a44 := JTF_VARCHAR2_TABLE_200();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_DATE_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_DATE_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_NUMBER_TABLE();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_300();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_1600();
      a57 := JTF_VARCHAR2_TABLE_1600();
      a58 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).program_id;
          a1(indx) := t(ddindx).program_type_id;
          a2(indx) := t(ddindx).custom_setup_id;
          a3(indx) := t(ddindx).program_level_code;
          a4(indx) := t(ddindx).program_parent_id;
          a5(indx) := t(ddindx).program_owner_resource_id;
          a6(indx) := t(ddindx).program_start_date;
          a7(indx) := t(ddindx).program_end_date;
          a8(indx) := t(ddindx).allow_enrl_until_date;
          a9(indx) := t(ddindx).citem_version_id;
          a10(indx) := t(ddindx).membership_valid_period;
          a11(indx) := t(ddindx).membership_period_unit;
          a12(indx) := t(ddindx).process_rule_id;
          a13(indx) := t(ddindx).prereq_process_rule_id;
          a14(indx) := t(ddindx).program_status_code;
          a15(indx) := t(ddindx).submit_child_nodes;
          a16(indx) := t(ddindx).inventory_item_id;
          a17(indx) := t(ddindx).inventory_item_org_id;
          a18(indx) := t(ddindx).bus_user_resp_id;
          a19(indx) := t(ddindx).admin_resp_id;
          a20(indx) := t(ddindx).no_fee_flag;
          a21(indx) := t(ddindx).vad_invite_allow_flag;
          a22(indx) := t(ddindx).global_mmbr_reqd_flag;
          a23(indx) := t(ddindx).waive_subsidiary_fee_flag;
          a24(indx) := t(ddindx).qsnr_ttl_all_page_dsp_flag;
          a25(indx) := t(ddindx).qsnr_hdr_all_page_dsp_flag;
          a26(indx) := t(ddindx).qsnr_ftr_all_page_dsp_flag;
          a27(indx) := t(ddindx).allow_enrl_wout_chklst_flag;
          a28(indx) := t(ddindx).user_status_id;
          a29(indx) := t(ddindx).enabled_flag;
          a30(indx) := t(ddindx).attribute_category;
          a31(indx) := t(ddindx).attribute1;
          a32(indx) := t(ddindx).attribute2;
          a33(indx) := t(ddindx).attribute3;
          a34(indx) := t(ddindx).attribute4;
          a35(indx) := t(ddindx).attribute5;
          a36(indx) := t(ddindx).attribute6;
          a37(indx) := t(ddindx).attribute7;
          a38(indx) := t(ddindx).attribute8;
          a39(indx) := t(ddindx).attribute9;
          a40(indx) := t(ddindx).attribute10;
          a41(indx) := t(ddindx).attribute11;
          a42(indx) := t(ddindx).attribute12;
          a43(indx) := t(ddindx).attribute13;
          a44(indx) := t(ddindx).attribute14;
          a45(indx) := t(ddindx).attribute15;
          a46(indx) := t(ddindx).last_update_date;
          a47(indx) := t(ddindx).last_updated_by;
          a48(indx) := t(ddindx).creation_date;
          a49(indx) := t(ddindx).created_by;
          a50(indx) := t(ddindx).last_update_login;
          a51(indx) := t(ddindx).object_version_number;
          a52(indx) := t(ddindx).program_name;
          a53(indx) := t(ddindx).program_description;
          a54(indx) := t(ddindx).source_lang;
          a55(indx) := t(ddindx).qsnr_title;
          a56(indx) := t(ddindx).qsnr_header;
          a57(indx) := t(ddindx).qsnr_footer;
          a58(indx) := t(ddindx).membership_fees;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_partner_program(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  NUMBER
    , p4_a5  NUMBER
    , p4_a6  DATE
    , p4_a7  DATE
    , p4_a8  DATE
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , p4_a11  VARCHAR2
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  NUMBER
    , p4_a17  NUMBER
    , p4_a18  NUMBER
    , p4_a19  NUMBER
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  NUMBER
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  VARCHAR2
    , p4_a46  DATE
    , p4_a47  NUMBER
    , p4_a48  DATE
    , p4_a49  NUMBER
    , p4_a50  NUMBER
    , p4_a51  NUMBER
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  VARCHAR2
    , p4_a55  VARCHAR2
    , p4_a56  VARCHAR2
    , p4_a57  VARCHAR2
    , p4_a58  NUMBER
    , p_identity_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_program_id out nocopy  NUMBER
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ptr_prgm_rec.program_id := p4_a0;
    ddp_ptr_prgm_rec.program_type_id := p4_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p4_a2;
    ddp_ptr_prgm_rec.program_level_code := p4_a3;
    ddp_ptr_prgm_rec.program_parent_id := p4_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p4_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p4_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p4_a8);
    ddp_ptr_prgm_rec.citem_version_id := p4_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p4_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p4_a11;
    ddp_ptr_prgm_rec.process_rule_id := p4_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p4_a13;
    ddp_ptr_prgm_rec.program_status_code := p4_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p4_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p4_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p4_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p4_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p4_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p4_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p4_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p4_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p4_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p4_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p4_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p4_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p4_a27;
    ddp_ptr_prgm_rec.user_status_id := p4_a28;
    ddp_ptr_prgm_rec.enabled_flag := p4_a29;
    ddp_ptr_prgm_rec.attribute_category := p4_a30;
    ddp_ptr_prgm_rec.attribute1 := p4_a31;
    ddp_ptr_prgm_rec.attribute2 := p4_a32;
    ddp_ptr_prgm_rec.attribute3 := p4_a33;
    ddp_ptr_prgm_rec.attribute4 := p4_a34;
    ddp_ptr_prgm_rec.attribute5 := p4_a35;
    ddp_ptr_prgm_rec.attribute6 := p4_a36;
    ddp_ptr_prgm_rec.attribute7 := p4_a37;
    ddp_ptr_prgm_rec.attribute8 := p4_a38;
    ddp_ptr_prgm_rec.attribute9 := p4_a39;
    ddp_ptr_prgm_rec.attribute10 := p4_a40;
    ddp_ptr_prgm_rec.attribute11 := p4_a41;
    ddp_ptr_prgm_rec.attribute12 := p4_a42;
    ddp_ptr_prgm_rec.attribute13 := p4_a43;
    ddp_ptr_prgm_rec.attribute14 := p4_a44;
    ddp_ptr_prgm_rec.attribute15 := p4_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a46);
    ddp_ptr_prgm_rec.last_updated_by := p4_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p4_a48);
    ddp_ptr_prgm_rec.created_by := p4_a49;
    ddp_ptr_prgm_rec.last_update_login := p4_a50;
    ddp_ptr_prgm_rec.object_version_number := p4_a51;
    ddp_ptr_prgm_rec.program_name := p4_a52;
    ddp_ptr_prgm_rec.program_description := p4_a53;
    ddp_ptr_prgm_rec.source_lang := p4_a54;
    ddp_ptr_prgm_rec.qsnr_title := p4_a55;
    ddp_ptr_prgm_rec.qsnr_header := p4_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p4_a57;
    ddp_ptr_prgm_rec.membership_fees := p4_a58;






    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.create_partner_program(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ptr_prgm_rec,
      p_identity_resource_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_program_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure update_partner_program(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  DATE
    , p7_a8  DATE
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  NUMBER
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
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  DATE
    , p7_a47  NUMBER
    , p7_a48  DATE
    , p7_a49  NUMBER
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  NUMBER
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ptr_prgm_rec.program_id := p7_a0;
    ddp_ptr_prgm_rec.program_type_id := p7_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p7_a2;
    ddp_ptr_prgm_rec.program_level_code := p7_a3;
    ddp_ptr_prgm_rec.program_parent_id := p7_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p7_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_ptr_prgm_rec.citem_version_id := p7_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p7_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p7_a11;
    ddp_ptr_prgm_rec.process_rule_id := p7_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p7_a13;
    ddp_ptr_prgm_rec.program_status_code := p7_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p7_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p7_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p7_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p7_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p7_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p7_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p7_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p7_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p7_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p7_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p7_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p7_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p7_a27;
    ddp_ptr_prgm_rec.user_status_id := p7_a28;
    ddp_ptr_prgm_rec.enabled_flag := p7_a29;
    ddp_ptr_prgm_rec.attribute_category := p7_a30;
    ddp_ptr_prgm_rec.attribute1 := p7_a31;
    ddp_ptr_prgm_rec.attribute2 := p7_a32;
    ddp_ptr_prgm_rec.attribute3 := p7_a33;
    ddp_ptr_prgm_rec.attribute4 := p7_a34;
    ddp_ptr_prgm_rec.attribute5 := p7_a35;
    ddp_ptr_prgm_rec.attribute6 := p7_a36;
    ddp_ptr_prgm_rec.attribute7 := p7_a37;
    ddp_ptr_prgm_rec.attribute8 := p7_a38;
    ddp_ptr_prgm_rec.attribute9 := p7_a39;
    ddp_ptr_prgm_rec.attribute10 := p7_a40;
    ddp_ptr_prgm_rec.attribute11 := p7_a41;
    ddp_ptr_prgm_rec.attribute12 := p7_a42;
    ddp_ptr_prgm_rec.attribute13 := p7_a43;
    ddp_ptr_prgm_rec.attribute14 := p7_a44;
    ddp_ptr_prgm_rec.attribute15 := p7_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a46);
    ddp_ptr_prgm_rec.last_updated_by := p7_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p7_a48);
    ddp_ptr_prgm_rec.created_by := p7_a49;
    ddp_ptr_prgm_rec.last_update_login := p7_a50;
    ddp_ptr_prgm_rec.object_version_number := p7_a51;
    ddp_ptr_prgm_rec.program_name := p7_a52;
    ddp_ptr_prgm_rec.program_description := p7_a53;
    ddp_ptr_prgm_rec.source_lang := p7_a54;
    ddp_ptr_prgm_rec.qsnr_title := p7_a55;
    ddp_ptr_prgm_rec.qsnr_header := p7_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p7_a57;
    ddp_ptr_prgm_rec.membership_fees := p7_a58;

    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.update_partner_program(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptr_prgm_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_partner_program(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  NUMBER
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  DATE
    , p3_a8  DATE
    , p3_a9  NUMBER
    , p3_a10  NUMBER
    , p3_a11  VARCHAR2
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  NUMBER
    , p3_a17  NUMBER
    , p3_a18  NUMBER
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  NUMBER
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  DATE
    , p3_a47  NUMBER
    , p3_a48  DATE
    , p3_a49  NUMBER
    , p3_a50  NUMBER
    , p3_a51  NUMBER
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ptr_prgm_rec.program_id := p3_a0;
    ddp_ptr_prgm_rec.program_type_id := p3_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p3_a2;
    ddp_ptr_prgm_rec.program_level_code := p3_a3;
    ddp_ptr_prgm_rec.program_parent_id := p3_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p3_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_ptr_prgm_rec.citem_version_id := p3_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p3_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p3_a11;
    ddp_ptr_prgm_rec.process_rule_id := p3_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p3_a13;
    ddp_ptr_prgm_rec.program_status_code := p3_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p3_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p3_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p3_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p3_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p3_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p3_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p3_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p3_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p3_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p3_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p3_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p3_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p3_a27;
    ddp_ptr_prgm_rec.user_status_id := p3_a28;
    ddp_ptr_prgm_rec.enabled_flag := p3_a29;
    ddp_ptr_prgm_rec.attribute_category := p3_a30;
    ddp_ptr_prgm_rec.attribute1 := p3_a31;
    ddp_ptr_prgm_rec.attribute2 := p3_a32;
    ddp_ptr_prgm_rec.attribute3 := p3_a33;
    ddp_ptr_prgm_rec.attribute4 := p3_a34;
    ddp_ptr_prgm_rec.attribute5 := p3_a35;
    ddp_ptr_prgm_rec.attribute6 := p3_a36;
    ddp_ptr_prgm_rec.attribute7 := p3_a37;
    ddp_ptr_prgm_rec.attribute8 := p3_a38;
    ddp_ptr_prgm_rec.attribute9 := p3_a39;
    ddp_ptr_prgm_rec.attribute10 := p3_a40;
    ddp_ptr_prgm_rec.attribute11 := p3_a41;
    ddp_ptr_prgm_rec.attribute12 := p3_a42;
    ddp_ptr_prgm_rec.attribute13 := p3_a43;
    ddp_ptr_prgm_rec.attribute14 := p3_a44;
    ddp_ptr_prgm_rec.attribute15 := p3_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a46);
    ddp_ptr_prgm_rec.last_updated_by := p3_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p3_a48);
    ddp_ptr_prgm_rec.created_by := p3_a49;
    ddp_ptr_prgm_rec.last_update_login := p3_a50;
    ddp_ptr_prgm_rec.object_version_number := p3_a51;
    ddp_ptr_prgm_rec.program_name := p3_a52;
    ddp_ptr_prgm_rec.program_description := p3_a53;
    ddp_ptr_prgm_rec.source_lang := p3_a54;
    ddp_ptr_prgm_rec.qsnr_title := p3_a55;
    ddp_ptr_prgm_rec.qsnr_header := p3_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p3_a57;
    ddp_ptr_prgm_rec.membership_fees := p3_a58;





    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.validate_partner_program(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ptr_prgm_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  DATE
    , p0_a47  NUMBER
    , p0_a48  DATE
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ptr_prgm_rec.program_id := p0_a0;
    ddp_ptr_prgm_rec.program_type_id := p0_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p0_a2;
    ddp_ptr_prgm_rec.program_level_code := p0_a3;
    ddp_ptr_prgm_rec.program_parent_id := p0_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p0_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_ptr_prgm_rec.citem_version_id := p0_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p0_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p0_a11;
    ddp_ptr_prgm_rec.process_rule_id := p0_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p0_a13;
    ddp_ptr_prgm_rec.program_status_code := p0_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p0_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p0_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p0_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p0_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p0_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p0_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p0_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p0_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p0_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p0_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p0_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p0_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p0_a27;
    ddp_ptr_prgm_rec.user_status_id := p0_a28;
    ddp_ptr_prgm_rec.enabled_flag := p0_a29;
    ddp_ptr_prgm_rec.attribute_category := p0_a30;
    ddp_ptr_prgm_rec.attribute1 := p0_a31;
    ddp_ptr_prgm_rec.attribute2 := p0_a32;
    ddp_ptr_prgm_rec.attribute3 := p0_a33;
    ddp_ptr_prgm_rec.attribute4 := p0_a34;
    ddp_ptr_prgm_rec.attribute5 := p0_a35;
    ddp_ptr_prgm_rec.attribute6 := p0_a36;
    ddp_ptr_prgm_rec.attribute7 := p0_a37;
    ddp_ptr_prgm_rec.attribute8 := p0_a38;
    ddp_ptr_prgm_rec.attribute9 := p0_a39;
    ddp_ptr_prgm_rec.attribute10 := p0_a40;
    ddp_ptr_prgm_rec.attribute11 := p0_a41;
    ddp_ptr_prgm_rec.attribute12 := p0_a42;
    ddp_ptr_prgm_rec.attribute13 := p0_a43;
    ddp_ptr_prgm_rec.attribute14 := p0_a44;
    ddp_ptr_prgm_rec.attribute15 := p0_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a46);
    ddp_ptr_prgm_rec.last_updated_by := p0_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p0_a48);
    ddp_ptr_prgm_rec.created_by := p0_a49;
    ddp_ptr_prgm_rec.last_update_login := p0_a50;
    ddp_ptr_prgm_rec.object_version_number := p0_a51;
    ddp_ptr_prgm_rec.program_name := p0_a52;
    ddp_ptr_prgm_rec.program_description := p0_a53;
    ddp_ptr_prgm_rec.source_lang := p0_a54;
    ddp_ptr_prgm_rec.qsnr_title := p0_a55;
    ddp_ptr_prgm_rec.qsnr_header := p0_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p0_a57;
    ddp_ptr_prgm_rec.membership_fees := p0_a58;



    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.check_items(ddp_ptr_prgm_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  DATE
    , p5_a8  DATE
    , p5_a9  NUMBER
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  NUMBER
    , p5_a17  NUMBER
    , p5_a18  NUMBER
    , p5_a19  NUMBER
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  NUMBER
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  VARCHAR2
    , p5_a36  VARCHAR2
    , p5_a37  VARCHAR2
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  VARCHAR2
    , p5_a46  DATE
    , p5_a47  NUMBER
    , p5_a48  DATE
    , p5_a49  NUMBER
    , p5_a50  NUMBER
    , p5_a51  NUMBER
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  VARCHAR2
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  NUMBER
    , p_validation_mode  VARCHAR2
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptr_prgm_rec.program_id := p5_a0;
    ddp_ptr_prgm_rec.program_type_id := p5_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p5_a2;
    ddp_ptr_prgm_rec.program_level_code := p5_a3;
    ddp_ptr_prgm_rec.program_parent_id := p5_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p5_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_ptr_prgm_rec.citem_version_id := p5_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p5_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p5_a11;
    ddp_ptr_prgm_rec.process_rule_id := p5_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p5_a13;
    ddp_ptr_prgm_rec.program_status_code := p5_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p5_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p5_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p5_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p5_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p5_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p5_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p5_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p5_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p5_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p5_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p5_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p5_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p5_a27;
    ddp_ptr_prgm_rec.user_status_id := p5_a28;
    ddp_ptr_prgm_rec.enabled_flag := p5_a29;
    ddp_ptr_prgm_rec.attribute_category := p5_a30;
    ddp_ptr_prgm_rec.attribute1 := p5_a31;
    ddp_ptr_prgm_rec.attribute2 := p5_a32;
    ddp_ptr_prgm_rec.attribute3 := p5_a33;
    ddp_ptr_prgm_rec.attribute4 := p5_a34;
    ddp_ptr_prgm_rec.attribute5 := p5_a35;
    ddp_ptr_prgm_rec.attribute6 := p5_a36;
    ddp_ptr_prgm_rec.attribute7 := p5_a37;
    ddp_ptr_prgm_rec.attribute8 := p5_a38;
    ddp_ptr_prgm_rec.attribute9 := p5_a39;
    ddp_ptr_prgm_rec.attribute10 := p5_a40;
    ddp_ptr_prgm_rec.attribute11 := p5_a41;
    ddp_ptr_prgm_rec.attribute12 := p5_a42;
    ddp_ptr_prgm_rec.attribute13 := p5_a43;
    ddp_ptr_prgm_rec.attribute14 := p5_a44;
    ddp_ptr_prgm_rec.attribute15 := p5_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_ptr_prgm_rec.last_updated_by := p5_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p5_a48);
    ddp_ptr_prgm_rec.created_by := p5_a49;
    ddp_ptr_prgm_rec.last_update_login := p5_a50;
    ddp_ptr_prgm_rec.object_version_number := p5_a51;
    ddp_ptr_prgm_rec.program_name := p5_a52;
    ddp_ptr_prgm_rec.program_description := p5_a53;
    ddp_ptr_prgm_rec.source_lang := p5_a54;
    ddp_ptr_prgm_rec.qsnr_title := p5_a55;
    ddp_ptr_prgm_rec.qsnr_header := p5_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p5_a57;
    ddp_ptr_prgm_rec.membership_fees := p5_a58;


    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.validate_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptr_prgm_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure complete_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  DATE
    , p0_a47  NUMBER
    , p0_a48  DATE
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  NUMBER
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  VARCHAR2
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  DATE
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  DATE
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  NUMBER
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  NUMBER
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  NUMBER
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  DATE
    , p1_a47 out nocopy  NUMBER
    , p1_a48 out nocopy  DATE
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  VARCHAR2
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  NUMBER
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddx_complete_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ptr_prgm_rec.program_id := p0_a0;
    ddp_ptr_prgm_rec.program_type_id := p0_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p0_a2;
    ddp_ptr_prgm_rec.program_level_code := p0_a3;
    ddp_ptr_prgm_rec.program_parent_id := p0_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p0_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_ptr_prgm_rec.citem_version_id := p0_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p0_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p0_a11;
    ddp_ptr_prgm_rec.process_rule_id := p0_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p0_a13;
    ddp_ptr_prgm_rec.program_status_code := p0_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p0_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p0_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p0_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p0_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p0_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p0_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p0_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p0_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p0_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p0_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p0_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p0_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p0_a27;
    ddp_ptr_prgm_rec.user_status_id := p0_a28;
    ddp_ptr_prgm_rec.enabled_flag := p0_a29;
    ddp_ptr_prgm_rec.attribute_category := p0_a30;
    ddp_ptr_prgm_rec.attribute1 := p0_a31;
    ddp_ptr_prgm_rec.attribute2 := p0_a32;
    ddp_ptr_prgm_rec.attribute3 := p0_a33;
    ddp_ptr_prgm_rec.attribute4 := p0_a34;
    ddp_ptr_prgm_rec.attribute5 := p0_a35;
    ddp_ptr_prgm_rec.attribute6 := p0_a36;
    ddp_ptr_prgm_rec.attribute7 := p0_a37;
    ddp_ptr_prgm_rec.attribute8 := p0_a38;
    ddp_ptr_prgm_rec.attribute9 := p0_a39;
    ddp_ptr_prgm_rec.attribute10 := p0_a40;
    ddp_ptr_prgm_rec.attribute11 := p0_a41;
    ddp_ptr_prgm_rec.attribute12 := p0_a42;
    ddp_ptr_prgm_rec.attribute13 := p0_a43;
    ddp_ptr_prgm_rec.attribute14 := p0_a44;
    ddp_ptr_prgm_rec.attribute15 := p0_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a46);
    ddp_ptr_prgm_rec.last_updated_by := p0_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p0_a48);
    ddp_ptr_prgm_rec.created_by := p0_a49;
    ddp_ptr_prgm_rec.last_update_login := p0_a50;
    ddp_ptr_prgm_rec.object_version_number := p0_a51;
    ddp_ptr_prgm_rec.program_name := p0_a52;
    ddp_ptr_prgm_rec.program_description := p0_a53;
    ddp_ptr_prgm_rec.source_lang := p0_a54;
    ddp_ptr_prgm_rec.qsnr_title := p0_a55;
    ddp_ptr_prgm_rec.qsnr_header := p0_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p0_a57;
    ddp_ptr_prgm_rec.membership_fees := p0_a58;


    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.complete_rec(ddp_ptr_prgm_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.program_id;
    p1_a1 := ddx_complete_rec.program_type_id;
    p1_a2 := ddx_complete_rec.custom_setup_id;
    p1_a3 := ddx_complete_rec.program_level_code;
    p1_a4 := ddx_complete_rec.program_parent_id;
    p1_a5 := ddx_complete_rec.program_owner_resource_id;
    p1_a6 := ddx_complete_rec.program_start_date;
    p1_a7 := ddx_complete_rec.program_end_date;
    p1_a8 := ddx_complete_rec.allow_enrl_until_date;
    p1_a9 := ddx_complete_rec.citem_version_id;
    p1_a10 := ddx_complete_rec.membership_valid_period;
    p1_a11 := ddx_complete_rec.membership_period_unit;
    p1_a12 := ddx_complete_rec.process_rule_id;
    p1_a13 := ddx_complete_rec.prereq_process_rule_id;
    p1_a14 := ddx_complete_rec.program_status_code;
    p1_a15 := ddx_complete_rec.submit_child_nodes;
    p1_a16 := ddx_complete_rec.inventory_item_id;
    p1_a17 := ddx_complete_rec.inventory_item_org_id;
    p1_a18 := ddx_complete_rec.bus_user_resp_id;
    p1_a19 := ddx_complete_rec.admin_resp_id;
    p1_a20 := ddx_complete_rec.no_fee_flag;
    p1_a21 := ddx_complete_rec.vad_invite_allow_flag;
    p1_a22 := ddx_complete_rec.global_mmbr_reqd_flag;
    p1_a23 := ddx_complete_rec.waive_subsidiary_fee_flag;
    p1_a24 := ddx_complete_rec.qsnr_ttl_all_page_dsp_flag;
    p1_a25 := ddx_complete_rec.qsnr_hdr_all_page_dsp_flag;
    p1_a26 := ddx_complete_rec.qsnr_ftr_all_page_dsp_flag;
    p1_a27 := ddx_complete_rec.allow_enrl_wout_chklst_flag;
    p1_a28 := ddx_complete_rec.user_status_id;
    p1_a29 := ddx_complete_rec.enabled_flag;
    p1_a30 := ddx_complete_rec.attribute_category;
    p1_a31 := ddx_complete_rec.attribute1;
    p1_a32 := ddx_complete_rec.attribute2;
    p1_a33 := ddx_complete_rec.attribute3;
    p1_a34 := ddx_complete_rec.attribute4;
    p1_a35 := ddx_complete_rec.attribute5;
    p1_a36 := ddx_complete_rec.attribute6;
    p1_a37 := ddx_complete_rec.attribute7;
    p1_a38 := ddx_complete_rec.attribute8;
    p1_a39 := ddx_complete_rec.attribute9;
    p1_a40 := ddx_complete_rec.attribute10;
    p1_a41 := ddx_complete_rec.attribute11;
    p1_a42 := ddx_complete_rec.attribute12;
    p1_a43 := ddx_complete_rec.attribute13;
    p1_a44 := ddx_complete_rec.attribute14;
    p1_a45 := ddx_complete_rec.attribute15;
    p1_a46 := ddx_complete_rec.last_update_date;
    p1_a47 := ddx_complete_rec.last_updated_by;
    p1_a48 := ddx_complete_rec.creation_date;
    p1_a49 := ddx_complete_rec.created_by;
    p1_a50 := ddx_complete_rec.last_update_login;
    p1_a51 := ddx_complete_rec.object_version_number;
    p1_a52 := ddx_complete_rec.program_name;
    p1_a53 := ddx_complete_rec.program_description;
    p1_a54 := ddx_complete_rec.source_lang;
    p1_a55 := ddx_complete_rec.qsnr_title;
    p1_a56 := ddx_complete_rec.qsnr_header;
    p1_a57 := ddx_complete_rec.qsnr_footer;
    p1_a58 := ddx_complete_rec.membership_fees;
  end;

  procedure create_pricelist_line(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  DATE
    , p0_a47  NUMBER
    , p0_a48  DATE
    , p0_a49  NUMBER
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  NUMBER
    , p_inventory_item_id  NUMBER
    , p_operation  VARCHAR2
    , p_list_header_id  NUMBER
    , p_pricing_attribute_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_pricelist_line_id out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ptr_prgm_rec pv_partner_program_pvt.ptr_prgm_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ptr_prgm_rec.program_id := p0_a0;
    ddp_ptr_prgm_rec.program_type_id := p0_a1;
    ddp_ptr_prgm_rec.custom_setup_id := p0_a2;
    ddp_ptr_prgm_rec.program_level_code := p0_a3;
    ddp_ptr_prgm_rec.program_parent_id := p0_a4;
    ddp_ptr_prgm_rec.program_owner_resource_id := p0_a5;
    ddp_ptr_prgm_rec.program_start_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ptr_prgm_rec.program_end_date := rosetta_g_miss_date_in_map(p0_a7);
    ddp_ptr_prgm_rec.allow_enrl_until_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_ptr_prgm_rec.citem_version_id := p0_a9;
    ddp_ptr_prgm_rec.membership_valid_period := p0_a10;
    ddp_ptr_prgm_rec.membership_period_unit := p0_a11;
    ddp_ptr_prgm_rec.process_rule_id := p0_a12;
    ddp_ptr_prgm_rec.prereq_process_rule_id := p0_a13;
    ddp_ptr_prgm_rec.program_status_code := p0_a14;
    ddp_ptr_prgm_rec.submit_child_nodes := p0_a15;
    ddp_ptr_prgm_rec.inventory_item_id := p0_a16;
    ddp_ptr_prgm_rec.inventory_item_org_id := p0_a17;
    ddp_ptr_prgm_rec.bus_user_resp_id := p0_a18;
    ddp_ptr_prgm_rec.admin_resp_id := p0_a19;
    ddp_ptr_prgm_rec.no_fee_flag := p0_a20;
    ddp_ptr_prgm_rec.vad_invite_allow_flag := p0_a21;
    ddp_ptr_prgm_rec.global_mmbr_reqd_flag := p0_a22;
    ddp_ptr_prgm_rec.waive_subsidiary_fee_flag := p0_a23;
    ddp_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag := p0_a24;
    ddp_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag := p0_a25;
    ddp_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag := p0_a26;
    ddp_ptr_prgm_rec.allow_enrl_wout_chklst_flag := p0_a27;
    ddp_ptr_prgm_rec.user_status_id := p0_a28;
    ddp_ptr_prgm_rec.enabled_flag := p0_a29;
    ddp_ptr_prgm_rec.attribute_category := p0_a30;
    ddp_ptr_prgm_rec.attribute1 := p0_a31;
    ddp_ptr_prgm_rec.attribute2 := p0_a32;
    ddp_ptr_prgm_rec.attribute3 := p0_a33;
    ddp_ptr_prgm_rec.attribute4 := p0_a34;
    ddp_ptr_prgm_rec.attribute5 := p0_a35;
    ddp_ptr_prgm_rec.attribute6 := p0_a36;
    ddp_ptr_prgm_rec.attribute7 := p0_a37;
    ddp_ptr_prgm_rec.attribute8 := p0_a38;
    ddp_ptr_prgm_rec.attribute9 := p0_a39;
    ddp_ptr_prgm_rec.attribute10 := p0_a40;
    ddp_ptr_prgm_rec.attribute11 := p0_a41;
    ddp_ptr_prgm_rec.attribute12 := p0_a42;
    ddp_ptr_prgm_rec.attribute13 := p0_a43;
    ddp_ptr_prgm_rec.attribute14 := p0_a44;
    ddp_ptr_prgm_rec.attribute15 := p0_a45;
    ddp_ptr_prgm_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a46);
    ddp_ptr_prgm_rec.last_updated_by := p0_a47;
    ddp_ptr_prgm_rec.creation_date := rosetta_g_miss_date_in_map(p0_a48);
    ddp_ptr_prgm_rec.created_by := p0_a49;
    ddp_ptr_prgm_rec.last_update_login := p0_a50;
    ddp_ptr_prgm_rec.object_version_number := p0_a51;
    ddp_ptr_prgm_rec.program_name := p0_a52;
    ddp_ptr_prgm_rec.program_description := p0_a53;
    ddp_ptr_prgm_rec.source_lang := p0_a54;
    ddp_ptr_prgm_rec.qsnr_title := p0_a55;
    ddp_ptr_prgm_rec.qsnr_header := p0_a56;
    ddp_ptr_prgm_rec.qsnr_footer := p0_a57;
    ddp_ptr_prgm_rec.membership_fees := p0_a58;









    -- here's the delegated call to the old PL/SQL routine
    pv_partner_program_pvt.create_pricelist_line(ddp_ptr_prgm_rec,
      p_inventory_item_id,
      p_operation,
      p_list_header_id,
      p_pricing_attribute_id,
      x_return_status,
      x_pricelist_line_id,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure copy_program(p_api_version_number  NUMBER
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
    pv_partner_program_pvt.copy_program(p_api_version_number,
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

end pv_partner_program_pvt_w;

/
