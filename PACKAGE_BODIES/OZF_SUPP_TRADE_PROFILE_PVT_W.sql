--------------------------------------------------------
--  DDL for Package Body OZF_SUPP_TRADE_PROFILE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SUPP_TRADE_PROFILE_PVT_W" as
  /* $Header: ozfwstpb.pls 120.0.12010000.5 2009/09/23 09:57:14 nepanda ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_supp_trade_profile_pvt.supp_trade_profile_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
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
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_NUMBER_TABLE
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
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
    , a57 JTF_VARCHAR2_TABLE_200
    , a58 JTF_VARCHAR2_TABLE_200
    , a59 JTF_VARCHAR2_TABLE_200
    , a60 JTF_VARCHAR2_TABLE_200
    , a61 JTF_VARCHAR2_TABLE_200
    , a62 JTF_VARCHAR2_TABLE_200
    , a63 JTF_VARCHAR2_TABLE_200
    , a64 JTF_VARCHAR2_TABLE_200
    , a65 JTF_VARCHAR2_TABLE_200
    , a66 JTF_VARCHAR2_TABLE_200
    , a67 JTF_VARCHAR2_TABLE_200
    , a68 JTF_VARCHAR2_TABLE_200
    , a69 JTF_VARCHAR2_TABLE_100
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
    , a82 JTF_VARCHAR2_TABLE_200
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
    , a98 JTF_VARCHAR2_TABLE_200
    , a99 JTF_VARCHAR2_TABLE_200
    , a100 JTF_NUMBER_TABLE
    , a101 JTF_NUMBER_TABLE
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_NUMBER_TABLE
    , a104 JTF_NUMBER_TABLE
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).supp_trade_profile_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_login := a6(indx);
          t(ddindx).request_id := a7(indx);
          t(ddindx).program_application_id := a8(indx);
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).program_id := a10(indx);
          t(ddindx).created_from := a11(indx);
          t(ddindx).supplier_id := a12(indx);
          t(ddindx).supplier_site_id := a13(indx);
          t(ddindx).party_id := a14(indx);
          t(ddindx).cust_account_id := a15(indx);
          t(ddindx).cust_acct_site_id := a16(indx);
          t(ddindx).site_use_id := a17(indx);
          t(ddindx).pre_approval_flag := a18(indx);
          t(ddindx).approval_communication := a19(indx);
          t(ddindx).gl_contra_liability_acct := a20(indx);
          t(ddindx).gl_cost_adjustment_acct := a21(indx);
          t(ddindx).default_days_covered := a22(indx);
          t(ddindx).create_claim_price_increase := a23(indx);
          t(ddindx).skip_approval_flag := a24(indx);
          t(ddindx).skip_adjustment_flag := a25(indx);
          t(ddindx).settlement_method_supplier_inc := a26(indx);
          t(ddindx).settlement_method_supplier_dec := a27(indx);
          t(ddindx).settlement_method_customer := a28(indx);
          t(ddindx).authorization_period := a29(indx);
          t(ddindx).grace_days := a30(indx);
          t(ddindx).allow_qty_increase := a31(indx);
          t(ddindx).qty_increase_tolerance := a32(indx);
          t(ddindx).request_communication := a33(indx);
          t(ddindx).claim_communication := a34(indx);
          t(ddindx).claim_frequency := a35(indx);
          t(ddindx).claim_frequency_unit := a36(indx);
          t(ddindx).claim_computation_basis := a37(indx);
          t(ddindx).attribute_category := a38(indx);
          t(ddindx).attribute1 := a39(indx);
          t(ddindx).attribute2 := a40(indx);
          t(ddindx).attribute3 := a41(indx);
          t(ddindx).attribute4 := a42(indx);
          t(ddindx).attribute5 := a43(indx);
          t(ddindx).attribute6 := a44(indx);
          t(ddindx).attribute7 := a45(indx);
          t(ddindx).attribute8 := a46(indx);
          t(ddindx).attribute9 := a47(indx);
          t(ddindx).attribute10 := a48(indx);
          t(ddindx).attribute11 := a49(indx);
          t(ddindx).attribute12 := a50(indx);
          t(ddindx).attribute13 := a51(indx);
          t(ddindx).attribute14 := a52(indx);
          t(ddindx).attribute15 := a53(indx);
          t(ddindx).attribute16 := a54(indx);
          t(ddindx).attribute17 := a55(indx);
          t(ddindx).attribute18 := a56(indx);
          t(ddindx).attribute19 := a57(indx);
          t(ddindx).attribute20 := a58(indx);
          t(ddindx).attribute21 := a59(indx);
          t(ddindx).attribute22 := a60(indx);
          t(ddindx).attribute23 := a61(indx);
          t(ddindx).attribute24 := a62(indx);
          t(ddindx).attribute25 := a63(indx);
          t(ddindx).attribute26 := a64(indx);
          t(ddindx).attribute27 := a65(indx);
          t(ddindx).attribute28 := a66(indx);
          t(ddindx).attribute29 := a67(indx);
          t(ddindx).attribute30 := a68(indx);
          t(ddindx).dpp_attribute_category := a69(indx);
          t(ddindx).dpp_attribute1 := a70(indx);
          t(ddindx).dpp_attribute2 := a71(indx);
          t(ddindx).dpp_attribute3 := a72(indx);
          t(ddindx).dpp_attribute4 := a73(indx);
          t(ddindx).dpp_attribute5 := a74(indx);
          t(ddindx).dpp_attribute6 := a75(indx);
          t(ddindx).dpp_attribute7 := a76(indx);
          t(ddindx).dpp_attribute8 := a77(indx);
          t(ddindx).dpp_attribute9 := a78(indx);
          t(ddindx).dpp_attribute10 := a79(indx);
          t(ddindx).dpp_attribute11 := a80(indx);
          t(ddindx).dpp_attribute12 := a81(indx);
          t(ddindx).dpp_attribute13 := a82(indx);
          t(ddindx).dpp_attribute14 := a83(indx);
          t(ddindx).dpp_attribute15 := a84(indx);
          t(ddindx).dpp_attribute16 := a85(indx);
          t(ddindx).dpp_attribute17 := a86(indx);
          t(ddindx).dpp_attribute18 := a87(indx);
          t(ddindx).dpp_attribute19 := a88(indx);
          t(ddindx).dpp_attribute20 := a89(indx);
          t(ddindx).dpp_attribute21 := a90(indx);
          t(ddindx).dpp_attribute22 := a91(indx);
          t(ddindx).dpp_attribute23 := a92(indx);
          t(ddindx).dpp_attribute24 := a93(indx);
          t(ddindx).dpp_attribute25 := a94(indx);
          t(ddindx).dpp_attribute26 := a95(indx);
          t(ddindx).dpp_attribute27 := a96(indx);
          t(ddindx).dpp_attribute28 := a97(indx);
          t(ddindx).dpp_attribute29 := a98(indx);
          t(ddindx).dpp_attribute30 := a99(indx);
          t(ddindx).org_id := a100(indx);
          t(ddindx).security_group_id := a101(indx);
          t(ddindx).claim_currency_code := a102(indx);
          t(ddindx).min_claim_amt := a103(indx);
          t(ddindx).min_claim_amt_line_lvl := a104(indx);
          t(ddindx).auto_debit := a105(indx);
          t(ddindx).days_before_claiming_debit := a106(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_supp_trade_profile_pvt.supp_trade_profile_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
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
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_NUMBER_TABLE
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a57 out nocopy JTF_VARCHAR2_TABLE_200
    , a58 out nocopy JTF_VARCHAR2_TABLE_200
    , a59 out nocopy JTF_VARCHAR2_TABLE_200
    , a60 out nocopy JTF_VARCHAR2_TABLE_200
    , a61 out nocopy JTF_VARCHAR2_TABLE_200
    , a62 out nocopy JTF_VARCHAR2_TABLE_200
    , a63 out nocopy JTF_VARCHAR2_TABLE_200
    , a64 out nocopy JTF_VARCHAR2_TABLE_200
    , a65 out nocopy JTF_VARCHAR2_TABLE_200
    , a66 out nocopy JTF_VARCHAR2_TABLE_200
    , a67 out nocopy JTF_VARCHAR2_TABLE_200
    , a68 out nocopy JTF_VARCHAR2_TABLE_200
    , a69 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a82 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a98 out nocopy JTF_VARCHAR2_TABLE_200
    , a99 out nocopy JTF_VARCHAR2_TABLE_200
    , a100 out nocopy JTF_NUMBER_TABLE
    , a101 out nocopy JTF_NUMBER_TABLE
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_NUMBER_TABLE
    , a104 out nocopy JTF_NUMBER_TABLE
    , a105 out nocopy JTF_VARCHAR2_TABLE_100
    , a106 out nocopy JTF_NUMBER_TABLE
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
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_NUMBER_TABLE();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_200();
    a40 := JTF_VARCHAR2_TABLE_200();
    a41 := JTF_VARCHAR2_TABLE_200();
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
    a57 := JTF_VARCHAR2_TABLE_200();
    a58 := JTF_VARCHAR2_TABLE_200();
    a59 := JTF_VARCHAR2_TABLE_200();
    a60 := JTF_VARCHAR2_TABLE_200();
    a61 := JTF_VARCHAR2_TABLE_200();
    a62 := JTF_VARCHAR2_TABLE_200();
    a63 := JTF_VARCHAR2_TABLE_200();
    a64 := JTF_VARCHAR2_TABLE_200();
    a65 := JTF_VARCHAR2_TABLE_200();
    a66 := JTF_VARCHAR2_TABLE_200();
    a67 := JTF_VARCHAR2_TABLE_200();
    a68 := JTF_VARCHAR2_TABLE_200();
    a69 := JTF_VARCHAR2_TABLE_100();
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
    a82 := JTF_VARCHAR2_TABLE_200();
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
    a98 := JTF_VARCHAR2_TABLE_200();
    a99 := JTF_VARCHAR2_TABLE_200();
    a100 := JTF_NUMBER_TABLE();
    a101 := JTF_NUMBER_TABLE();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_NUMBER_TABLE();
    a104 := JTF_NUMBER_TABLE();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_NUMBER_TABLE();
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
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_NUMBER_TABLE();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_200();
      a40 := JTF_VARCHAR2_TABLE_200();
      a41 := JTF_VARCHAR2_TABLE_200();
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
      a57 := JTF_VARCHAR2_TABLE_200();
      a58 := JTF_VARCHAR2_TABLE_200();
      a59 := JTF_VARCHAR2_TABLE_200();
      a60 := JTF_VARCHAR2_TABLE_200();
      a61 := JTF_VARCHAR2_TABLE_200();
      a62 := JTF_VARCHAR2_TABLE_200();
      a63 := JTF_VARCHAR2_TABLE_200();
      a64 := JTF_VARCHAR2_TABLE_200();
      a65 := JTF_VARCHAR2_TABLE_200();
      a66 := JTF_VARCHAR2_TABLE_200();
      a67 := JTF_VARCHAR2_TABLE_200();
      a68 := JTF_VARCHAR2_TABLE_200();
      a69 := JTF_VARCHAR2_TABLE_100();
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
      a82 := JTF_VARCHAR2_TABLE_200();
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
      a98 := JTF_VARCHAR2_TABLE_200();
      a99 := JTF_VARCHAR2_TABLE_200();
      a100 := JTF_NUMBER_TABLE();
      a101 := JTF_NUMBER_TABLE();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_NUMBER_TABLE();
      a104 := JTF_NUMBER_TABLE();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_NUMBER_TABLE();
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
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).supp_trade_profile_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := t(ddindx).last_updated_by;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_login;
          a7(indx) := t(ddindx).request_id;
          a8(indx) := t(ddindx).program_application_id;
          a9(indx) := t(ddindx).program_update_date;
          a10(indx) := t(ddindx).program_id;
          a11(indx) := t(ddindx).created_from;
          a12(indx) := t(ddindx).supplier_id;
          a13(indx) := t(ddindx).supplier_site_id;
          a14(indx) := t(ddindx).party_id;
          a15(indx) := t(ddindx).cust_account_id;
          a16(indx) := t(ddindx).cust_acct_site_id;
          a17(indx) := t(ddindx).site_use_id;
          a18(indx) := t(ddindx).pre_approval_flag;
          a19(indx) := t(ddindx).approval_communication;
          a20(indx) := t(ddindx).gl_contra_liability_acct;
          a21(indx) := t(ddindx).gl_cost_adjustment_acct;
          a22(indx) := t(ddindx).default_days_covered;
          a23(indx) := t(ddindx).create_claim_price_increase;
          a24(indx) := t(ddindx).skip_approval_flag;
          a25(indx) := t(ddindx).skip_adjustment_flag;
          a26(indx) := t(ddindx).settlement_method_supplier_inc;
          a27(indx) := t(ddindx).settlement_method_supplier_dec;
          a28(indx) := t(ddindx).settlement_method_customer;
          a29(indx) := t(ddindx).authorization_period;
          a30(indx) := t(ddindx).grace_days;
          a31(indx) := t(ddindx).allow_qty_increase;
          a32(indx) := t(ddindx).qty_increase_tolerance;
          a33(indx) := t(ddindx).request_communication;
          a34(indx) := t(ddindx).claim_communication;
          a35(indx) := t(ddindx).claim_frequency;
          a36(indx) := t(ddindx).claim_frequency_unit;
          a37(indx) := t(ddindx).claim_computation_basis;
          a38(indx) := t(ddindx).attribute_category;
          a39(indx) := t(ddindx).attribute1;
          a40(indx) := t(ddindx).attribute2;
          a41(indx) := t(ddindx).attribute3;
          a42(indx) := t(ddindx).attribute4;
          a43(indx) := t(ddindx).attribute5;
          a44(indx) := t(ddindx).attribute6;
          a45(indx) := t(ddindx).attribute7;
          a46(indx) := t(ddindx).attribute8;
          a47(indx) := t(ddindx).attribute9;
          a48(indx) := t(ddindx).attribute10;
          a49(indx) := t(ddindx).attribute11;
          a50(indx) := t(ddindx).attribute12;
          a51(indx) := t(ddindx).attribute13;
          a52(indx) := t(ddindx).attribute14;
          a53(indx) := t(ddindx).attribute15;
          a54(indx) := t(ddindx).attribute16;
          a55(indx) := t(ddindx).attribute17;
          a56(indx) := t(ddindx).attribute18;
          a57(indx) := t(ddindx).attribute19;
          a58(indx) := t(ddindx).attribute20;
          a59(indx) := t(ddindx).attribute21;
          a60(indx) := t(ddindx).attribute22;
          a61(indx) := t(ddindx).attribute23;
          a62(indx) := t(ddindx).attribute24;
          a63(indx) := t(ddindx).attribute25;
          a64(indx) := t(ddindx).attribute26;
          a65(indx) := t(ddindx).attribute27;
          a66(indx) := t(ddindx).attribute28;
          a67(indx) := t(ddindx).attribute29;
          a68(indx) := t(ddindx).attribute30;
          a69(indx) := t(ddindx).dpp_attribute_category;
          a70(indx) := t(ddindx).dpp_attribute1;
          a71(indx) := t(ddindx).dpp_attribute2;
          a72(indx) := t(ddindx).dpp_attribute3;
          a73(indx) := t(ddindx).dpp_attribute4;
          a74(indx) := t(ddindx).dpp_attribute5;
          a75(indx) := t(ddindx).dpp_attribute6;
          a76(indx) := t(ddindx).dpp_attribute7;
          a77(indx) := t(ddindx).dpp_attribute8;
          a78(indx) := t(ddindx).dpp_attribute9;
          a79(indx) := t(ddindx).dpp_attribute10;
          a80(indx) := t(ddindx).dpp_attribute11;
          a81(indx) := t(ddindx).dpp_attribute12;
          a82(indx) := t(ddindx).dpp_attribute13;
          a83(indx) := t(ddindx).dpp_attribute14;
          a84(indx) := t(ddindx).dpp_attribute15;
          a85(indx) := t(ddindx).dpp_attribute16;
          a86(indx) := t(ddindx).dpp_attribute17;
          a87(indx) := t(ddindx).dpp_attribute18;
          a88(indx) := t(ddindx).dpp_attribute19;
          a89(indx) := t(ddindx).dpp_attribute20;
          a90(indx) := t(ddindx).dpp_attribute21;
          a91(indx) := t(ddindx).dpp_attribute22;
          a92(indx) := t(ddindx).dpp_attribute23;
          a93(indx) := t(ddindx).dpp_attribute24;
          a94(indx) := t(ddindx).dpp_attribute25;
          a95(indx) := t(ddindx).dpp_attribute26;
          a96(indx) := t(ddindx).dpp_attribute27;
          a97(indx) := t(ddindx).dpp_attribute28;
          a98(indx) := t(ddindx).dpp_attribute29;
          a99(indx) := t(ddindx).dpp_attribute30;
          a100(indx) := t(ddindx).org_id;
          a101(indx) := t(ddindx).security_group_id;
          a102(indx) := t(ddindx).claim_currency_code;
          a103(indx) := t(ddindx).min_claim_amt;
          a104(indx) := t(ddindx).min_claim_amt_line_lvl;
          a105(indx) := t(ddindx).auto_debit;
          a106(indx) := t(ddindx).days_before_claiming_debit;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_supp_trade_profile(p_api_version_number  NUMBER
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
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  VARCHAR2
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  VARCHAR2
    , p7_a106  NUMBER
    , x_supp_trade_profile_id out nocopy  NUMBER
  )

  as
    ddp_supp_trade_profile_rec ozf_supp_trade_profile_pvt.supp_trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_supp_trade_profile_rec.supp_trade_profile_id := p7_a0;
    ddp_supp_trade_profile_rec.object_version_number := p7_a1;
    ddp_supp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_supp_trade_profile_rec.last_updated_by := p7_a3;
    ddp_supp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_supp_trade_profile_rec.created_by := p7_a5;
    ddp_supp_trade_profile_rec.last_update_login := p7_a6;
    ddp_supp_trade_profile_rec.request_id := p7_a7;
    ddp_supp_trade_profile_rec.program_application_id := p7_a8;
    ddp_supp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_supp_trade_profile_rec.program_id := p7_a10;
    ddp_supp_trade_profile_rec.created_from := p7_a11;
    ddp_supp_trade_profile_rec.supplier_id := p7_a12;
    ddp_supp_trade_profile_rec.supplier_site_id := p7_a13;
    ddp_supp_trade_profile_rec.party_id := p7_a14;
    ddp_supp_trade_profile_rec.cust_account_id := p7_a15;
    ddp_supp_trade_profile_rec.cust_acct_site_id := p7_a16;
    ddp_supp_trade_profile_rec.site_use_id := p7_a17;
    ddp_supp_trade_profile_rec.pre_approval_flag := p7_a18;
    ddp_supp_trade_profile_rec.approval_communication := p7_a19;
    ddp_supp_trade_profile_rec.gl_contra_liability_acct := p7_a20;
    ddp_supp_trade_profile_rec.gl_cost_adjustment_acct := p7_a21;
    ddp_supp_trade_profile_rec.default_days_covered := p7_a22;
    ddp_supp_trade_profile_rec.create_claim_price_increase := p7_a23;
    ddp_supp_trade_profile_rec.skip_approval_flag := p7_a24;
    ddp_supp_trade_profile_rec.skip_adjustment_flag := p7_a25;
    ddp_supp_trade_profile_rec.settlement_method_supplier_inc := p7_a26;
    ddp_supp_trade_profile_rec.settlement_method_supplier_dec := p7_a27;
    ddp_supp_trade_profile_rec.settlement_method_customer := p7_a28;
    ddp_supp_trade_profile_rec.authorization_period := p7_a29;
    ddp_supp_trade_profile_rec.grace_days := p7_a30;
    ddp_supp_trade_profile_rec.allow_qty_increase := p7_a31;
    ddp_supp_trade_profile_rec.qty_increase_tolerance := p7_a32;
    ddp_supp_trade_profile_rec.request_communication := p7_a33;
    ddp_supp_trade_profile_rec.claim_communication := p7_a34;
    ddp_supp_trade_profile_rec.claim_frequency := p7_a35;
    ddp_supp_trade_profile_rec.claim_frequency_unit := p7_a36;
    ddp_supp_trade_profile_rec.claim_computation_basis := p7_a37;
    ddp_supp_trade_profile_rec.attribute_category := p7_a38;
    ddp_supp_trade_profile_rec.attribute1 := p7_a39;
    ddp_supp_trade_profile_rec.attribute2 := p7_a40;
    ddp_supp_trade_profile_rec.attribute3 := p7_a41;
    ddp_supp_trade_profile_rec.attribute4 := p7_a42;
    ddp_supp_trade_profile_rec.attribute5 := p7_a43;
    ddp_supp_trade_profile_rec.attribute6 := p7_a44;
    ddp_supp_trade_profile_rec.attribute7 := p7_a45;
    ddp_supp_trade_profile_rec.attribute8 := p7_a46;
    ddp_supp_trade_profile_rec.attribute9 := p7_a47;
    ddp_supp_trade_profile_rec.attribute10 := p7_a48;
    ddp_supp_trade_profile_rec.attribute11 := p7_a49;
    ddp_supp_trade_profile_rec.attribute12 := p7_a50;
    ddp_supp_trade_profile_rec.attribute13 := p7_a51;
    ddp_supp_trade_profile_rec.attribute14 := p7_a52;
    ddp_supp_trade_profile_rec.attribute15 := p7_a53;
    ddp_supp_trade_profile_rec.attribute16 := p7_a54;
    ddp_supp_trade_profile_rec.attribute17 := p7_a55;
    ddp_supp_trade_profile_rec.attribute18 := p7_a56;
    ddp_supp_trade_profile_rec.attribute19 := p7_a57;
    ddp_supp_trade_profile_rec.attribute20 := p7_a58;
    ddp_supp_trade_profile_rec.attribute21 := p7_a59;
    ddp_supp_trade_profile_rec.attribute22 := p7_a60;
    ddp_supp_trade_profile_rec.attribute23 := p7_a61;
    ddp_supp_trade_profile_rec.attribute24 := p7_a62;
    ddp_supp_trade_profile_rec.attribute25 := p7_a63;
    ddp_supp_trade_profile_rec.attribute26 := p7_a64;
    ddp_supp_trade_profile_rec.attribute27 := p7_a65;
    ddp_supp_trade_profile_rec.attribute28 := p7_a66;
    ddp_supp_trade_profile_rec.attribute29 := p7_a67;
    ddp_supp_trade_profile_rec.attribute30 := p7_a68;
    ddp_supp_trade_profile_rec.dpp_attribute_category := p7_a69;
    ddp_supp_trade_profile_rec.dpp_attribute1 := p7_a70;
    ddp_supp_trade_profile_rec.dpp_attribute2 := p7_a71;
    ddp_supp_trade_profile_rec.dpp_attribute3 := p7_a72;
    ddp_supp_trade_profile_rec.dpp_attribute4 := p7_a73;
    ddp_supp_trade_profile_rec.dpp_attribute5 := p7_a74;
    ddp_supp_trade_profile_rec.dpp_attribute6 := p7_a75;
    ddp_supp_trade_profile_rec.dpp_attribute7 := p7_a76;
    ddp_supp_trade_profile_rec.dpp_attribute8 := p7_a77;
    ddp_supp_trade_profile_rec.dpp_attribute9 := p7_a78;
    ddp_supp_trade_profile_rec.dpp_attribute10 := p7_a79;
    ddp_supp_trade_profile_rec.dpp_attribute11 := p7_a80;
    ddp_supp_trade_profile_rec.dpp_attribute12 := p7_a81;
    ddp_supp_trade_profile_rec.dpp_attribute13 := p7_a82;
    ddp_supp_trade_profile_rec.dpp_attribute14 := p7_a83;
    ddp_supp_trade_profile_rec.dpp_attribute15 := p7_a84;
    ddp_supp_trade_profile_rec.dpp_attribute16 := p7_a85;
    ddp_supp_trade_profile_rec.dpp_attribute17 := p7_a86;
    ddp_supp_trade_profile_rec.dpp_attribute18 := p7_a87;
    ddp_supp_trade_profile_rec.dpp_attribute19 := p7_a88;
    ddp_supp_trade_profile_rec.dpp_attribute20 := p7_a89;
    ddp_supp_trade_profile_rec.dpp_attribute21 := p7_a90;
    ddp_supp_trade_profile_rec.dpp_attribute22 := p7_a91;
    ddp_supp_trade_profile_rec.dpp_attribute23 := p7_a92;
    ddp_supp_trade_profile_rec.dpp_attribute24 := p7_a93;
    ddp_supp_trade_profile_rec.dpp_attribute25 := p7_a94;
    ddp_supp_trade_profile_rec.dpp_attribute26 := p7_a95;
    ddp_supp_trade_profile_rec.dpp_attribute27 := p7_a96;
    ddp_supp_trade_profile_rec.dpp_attribute28 := p7_a97;
    ddp_supp_trade_profile_rec.dpp_attribute29 := p7_a98;
    ddp_supp_trade_profile_rec.dpp_attribute30 := p7_a99;
    ddp_supp_trade_profile_rec.org_id := p7_a100;
    ddp_supp_trade_profile_rec.security_group_id := p7_a101;
    ddp_supp_trade_profile_rec.claim_currency_code := p7_a102;
    ddp_supp_trade_profile_rec.min_claim_amt := p7_a103;
    ddp_supp_trade_profile_rec.min_claim_amt_line_lvl := p7_a104;
    ddp_supp_trade_profile_rec.auto_debit := p7_a105;
    ddp_supp_trade_profile_rec.days_before_claiming_debit := p7_a106;


    -- here's the delegated call to the old PL/SQL routine
    ozf_supp_trade_profile_pvt.create_supp_trade_profile(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_supp_trade_profile_rec,
      x_supp_trade_profile_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_supp_trade_profile(p_api_version_number  NUMBER
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
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  NUMBER
    , p7_a15  NUMBER
    , p7_a16  NUMBER
    , p7_a17  NUMBER
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  VARCHAR2
    , p7_a32  NUMBER
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  NUMBER
    , p7_a36  VARCHAR2
    , p7_a37  NUMBER
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  VARCHAR2
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  VARCHAR2
    , p7_a56  VARCHAR2
    , p7_a57  VARCHAR2
    , p7_a58  VARCHAR2
    , p7_a59  VARCHAR2
    , p7_a60  VARCHAR2
    , p7_a61  VARCHAR2
    , p7_a62  VARCHAR2
    , p7_a63  VARCHAR2
    , p7_a64  VARCHAR2
    , p7_a65  VARCHAR2
    , p7_a66  VARCHAR2
    , p7_a67  VARCHAR2
    , p7_a68  VARCHAR2
    , p7_a69  VARCHAR2
    , p7_a70  VARCHAR2
    , p7_a71  VARCHAR2
    , p7_a72  VARCHAR2
    , p7_a73  VARCHAR2
    , p7_a74  VARCHAR2
    , p7_a75  VARCHAR2
    , p7_a76  VARCHAR2
    , p7_a77  VARCHAR2
    , p7_a78  VARCHAR2
    , p7_a79  VARCHAR2
    , p7_a80  VARCHAR2
    , p7_a81  VARCHAR2
    , p7_a82  VARCHAR2
    , p7_a83  VARCHAR2
    , p7_a84  VARCHAR2
    , p7_a85  VARCHAR2
    , p7_a86  VARCHAR2
    , p7_a87  VARCHAR2
    , p7_a88  VARCHAR2
    , p7_a89  VARCHAR2
    , p7_a90  VARCHAR2
    , p7_a91  VARCHAR2
    , p7_a92  VARCHAR2
    , p7_a93  VARCHAR2
    , p7_a94  VARCHAR2
    , p7_a95  VARCHAR2
    , p7_a96  VARCHAR2
    , p7_a97  VARCHAR2
    , p7_a98  VARCHAR2
    , p7_a99  VARCHAR2
    , p7_a100  NUMBER
    , p7_a101  NUMBER
    , p7_a102  VARCHAR2
    , p7_a103  NUMBER
    , p7_a104  NUMBER
    , p7_a105  VARCHAR2
    , p7_a106  NUMBER
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_supp_trade_profile_rec ozf_supp_trade_profile_pvt.supp_trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_supp_trade_profile_rec.supp_trade_profile_id := p7_a0;
    ddp_supp_trade_profile_rec.object_version_number := p7_a1;
    ddp_supp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_supp_trade_profile_rec.last_updated_by := p7_a3;
    ddp_supp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_supp_trade_profile_rec.created_by := p7_a5;
    ddp_supp_trade_profile_rec.last_update_login := p7_a6;
    ddp_supp_trade_profile_rec.request_id := p7_a7;
    ddp_supp_trade_profile_rec.program_application_id := p7_a8;
    ddp_supp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_supp_trade_profile_rec.program_id := p7_a10;
    ddp_supp_trade_profile_rec.created_from := p7_a11;
    ddp_supp_trade_profile_rec.supplier_id := p7_a12;
    ddp_supp_trade_profile_rec.supplier_site_id := p7_a13;
    ddp_supp_trade_profile_rec.party_id := p7_a14;
    ddp_supp_trade_profile_rec.cust_account_id := p7_a15;
    ddp_supp_trade_profile_rec.cust_acct_site_id := p7_a16;
    ddp_supp_trade_profile_rec.site_use_id := p7_a17;
    ddp_supp_trade_profile_rec.pre_approval_flag := p7_a18;
    ddp_supp_trade_profile_rec.approval_communication := p7_a19;
    ddp_supp_trade_profile_rec.gl_contra_liability_acct := p7_a20;
    ddp_supp_trade_profile_rec.gl_cost_adjustment_acct := p7_a21;
    ddp_supp_trade_profile_rec.default_days_covered := p7_a22;
    ddp_supp_trade_profile_rec.create_claim_price_increase := p7_a23;
    ddp_supp_trade_profile_rec.skip_approval_flag := p7_a24;
    ddp_supp_trade_profile_rec.skip_adjustment_flag := p7_a25;
    ddp_supp_trade_profile_rec.settlement_method_supplier_inc := p7_a26;
    ddp_supp_trade_profile_rec.settlement_method_supplier_dec := p7_a27;
    ddp_supp_trade_profile_rec.settlement_method_customer := p7_a28;
    ddp_supp_trade_profile_rec.authorization_period := p7_a29;
    ddp_supp_trade_profile_rec.grace_days := p7_a30;
    ddp_supp_trade_profile_rec.allow_qty_increase := p7_a31;
    ddp_supp_trade_profile_rec.qty_increase_tolerance := p7_a32;
    ddp_supp_trade_profile_rec.request_communication := p7_a33;
    ddp_supp_trade_profile_rec.claim_communication := p7_a34;
    ddp_supp_trade_profile_rec.claim_frequency := p7_a35;
    ddp_supp_trade_profile_rec.claim_frequency_unit := p7_a36;
    ddp_supp_trade_profile_rec.claim_computation_basis := p7_a37;
    ddp_supp_trade_profile_rec.attribute_category := p7_a38;
    ddp_supp_trade_profile_rec.attribute1 := p7_a39;
    ddp_supp_trade_profile_rec.attribute2 := p7_a40;
    ddp_supp_trade_profile_rec.attribute3 := p7_a41;
    ddp_supp_trade_profile_rec.attribute4 := p7_a42;
    ddp_supp_trade_profile_rec.attribute5 := p7_a43;
    ddp_supp_trade_profile_rec.attribute6 := p7_a44;
    ddp_supp_trade_profile_rec.attribute7 := p7_a45;
    ddp_supp_trade_profile_rec.attribute8 := p7_a46;
    ddp_supp_trade_profile_rec.attribute9 := p7_a47;
    ddp_supp_trade_profile_rec.attribute10 := p7_a48;
    ddp_supp_trade_profile_rec.attribute11 := p7_a49;
    ddp_supp_trade_profile_rec.attribute12 := p7_a50;
    ddp_supp_trade_profile_rec.attribute13 := p7_a51;
    ddp_supp_trade_profile_rec.attribute14 := p7_a52;
    ddp_supp_trade_profile_rec.attribute15 := p7_a53;
    ddp_supp_trade_profile_rec.attribute16 := p7_a54;
    ddp_supp_trade_profile_rec.attribute17 := p7_a55;
    ddp_supp_trade_profile_rec.attribute18 := p7_a56;
    ddp_supp_trade_profile_rec.attribute19 := p7_a57;
    ddp_supp_trade_profile_rec.attribute20 := p7_a58;
    ddp_supp_trade_profile_rec.attribute21 := p7_a59;
    ddp_supp_trade_profile_rec.attribute22 := p7_a60;
    ddp_supp_trade_profile_rec.attribute23 := p7_a61;
    ddp_supp_trade_profile_rec.attribute24 := p7_a62;
    ddp_supp_trade_profile_rec.attribute25 := p7_a63;
    ddp_supp_trade_profile_rec.attribute26 := p7_a64;
    ddp_supp_trade_profile_rec.attribute27 := p7_a65;
    ddp_supp_trade_profile_rec.attribute28 := p7_a66;
    ddp_supp_trade_profile_rec.attribute29 := p7_a67;
    ddp_supp_trade_profile_rec.attribute30 := p7_a68;
    ddp_supp_trade_profile_rec.dpp_attribute_category := p7_a69;
    ddp_supp_trade_profile_rec.dpp_attribute1 := p7_a70;
    ddp_supp_trade_profile_rec.dpp_attribute2 := p7_a71;
    ddp_supp_trade_profile_rec.dpp_attribute3 := p7_a72;
    ddp_supp_trade_profile_rec.dpp_attribute4 := p7_a73;
    ddp_supp_trade_profile_rec.dpp_attribute5 := p7_a74;
    ddp_supp_trade_profile_rec.dpp_attribute6 := p7_a75;
    ddp_supp_trade_profile_rec.dpp_attribute7 := p7_a76;
    ddp_supp_trade_profile_rec.dpp_attribute8 := p7_a77;
    ddp_supp_trade_profile_rec.dpp_attribute9 := p7_a78;
    ddp_supp_trade_profile_rec.dpp_attribute10 := p7_a79;
    ddp_supp_trade_profile_rec.dpp_attribute11 := p7_a80;
    ddp_supp_trade_profile_rec.dpp_attribute12 := p7_a81;
    ddp_supp_trade_profile_rec.dpp_attribute13 := p7_a82;
    ddp_supp_trade_profile_rec.dpp_attribute14 := p7_a83;
    ddp_supp_trade_profile_rec.dpp_attribute15 := p7_a84;
    ddp_supp_trade_profile_rec.dpp_attribute16 := p7_a85;
    ddp_supp_trade_profile_rec.dpp_attribute17 := p7_a86;
    ddp_supp_trade_profile_rec.dpp_attribute18 := p7_a87;
    ddp_supp_trade_profile_rec.dpp_attribute19 := p7_a88;
    ddp_supp_trade_profile_rec.dpp_attribute20 := p7_a89;
    ddp_supp_trade_profile_rec.dpp_attribute21 := p7_a90;
    ddp_supp_trade_profile_rec.dpp_attribute22 := p7_a91;
    ddp_supp_trade_profile_rec.dpp_attribute23 := p7_a92;
    ddp_supp_trade_profile_rec.dpp_attribute24 := p7_a93;
    ddp_supp_trade_profile_rec.dpp_attribute25 := p7_a94;
    ddp_supp_trade_profile_rec.dpp_attribute26 := p7_a95;
    ddp_supp_trade_profile_rec.dpp_attribute27 := p7_a96;
    ddp_supp_trade_profile_rec.dpp_attribute28 := p7_a97;
    ddp_supp_trade_profile_rec.dpp_attribute29 := p7_a98;
    ddp_supp_trade_profile_rec.dpp_attribute30 := p7_a99;
    ddp_supp_trade_profile_rec.org_id := p7_a100;
    ddp_supp_trade_profile_rec.security_group_id := p7_a101;
    ddp_supp_trade_profile_rec.claim_currency_code := p7_a102;
    ddp_supp_trade_profile_rec.min_claim_amt := p7_a103;
    ddp_supp_trade_profile_rec.min_claim_amt_line_lvl := p7_a104;
    ddp_supp_trade_profile_rec.auto_debit := p7_a105;
    ddp_supp_trade_profile_rec.days_before_claiming_debit := p7_a106;


    -- here's the delegated call to the old PL/SQL routine
    ozf_supp_trade_profile_pvt.update_supp_trade_profile(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_supp_trade_profile_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_supp_trade_profile(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  NUMBER
    , p3_a11  VARCHAR2
    , p3_a12  NUMBER
    , p3_a13  NUMBER
    , p3_a14  NUMBER
    , p3_a15  NUMBER
    , p3_a16  NUMBER
    , p3_a17  NUMBER
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  NUMBER
    , p3_a21  NUMBER
    , p3_a22  NUMBER
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  VARCHAR2
    , p3_a32  NUMBER
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  NUMBER
    , p3_a36  VARCHAR2
    , p3_a37  NUMBER
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  VARCHAR2
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  VARCHAR2
    , p3_a62  VARCHAR2
    , p3_a63  VARCHAR2
    , p3_a64  VARCHAR2
    , p3_a65  VARCHAR2
    , p3_a66  VARCHAR2
    , p3_a67  VARCHAR2
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  VARCHAR2
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  VARCHAR2
    , p3_a81  VARCHAR2
    , p3_a82  VARCHAR2
    , p3_a83  VARCHAR2
    , p3_a84  VARCHAR2
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  VARCHAR2
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  VARCHAR2
    , p3_a97  VARCHAR2
    , p3_a98  VARCHAR2
    , p3_a99  VARCHAR2
    , p3_a100  NUMBER
    , p3_a101  NUMBER
    , p3_a102  VARCHAR2
    , p3_a103  NUMBER
    , p3_a104  NUMBER
    , p3_a105  VARCHAR2
    , p3_a106  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_supp_trade_profile_rec ozf_supp_trade_profile_pvt.supp_trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_supp_trade_profile_rec.supp_trade_profile_id := p3_a0;
    ddp_supp_trade_profile_rec.object_version_number := p3_a1;
    ddp_supp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_supp_trade_profile_rec.last_updated_by := p3_a3;
    ddp_supp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_supp_trade_profile_rec.created_by := p3_a5;
    ddp_supp_trade_profile_rec.last_update_login := p3_a6;
    ddp_supp_trade_profile_rec.request_id := p3_a7;
    ddp_supp_trade_profile_rec.program_application_id := p3_a8;
    ddp_supp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_supp_trade_profile_rec.program_id := p3_a10;
    ddp_supp_trade_profile_rec.created_from := p3_a11;
    ddp_supp_trade_profile_rec.supplier_id := p3_a12;
    ddp_supp_trade_profile_rec.supplier_site_id := p3_a13;
    ddp_supp_trade_profile_rec.party_id := p3_a14;
    ddp_supp_trade_profile_rec.cust_account_id := p3_a15;
    ddp_supp_trade_profile_rec.cust_acct_site_id := p3_a16;
    ddp_supp_trade_profile_rec.site_use_id := p3_a17;
    ddp_supp_trade_profile_rec.pre_approval_flag := p3_a18;
    ddp_supp_trade_profile_rec.approval_communication := p3_a19;
    ddp_supp_trade_profile_rec.gl_contra_liability_acct := p3_a20;
    ddp_supp_trade_profile_rec.gl_cost_adjustment_acct := p3_a21;
    ddp_supp_trade_profile_rec.default_days_covered := p3_a22;
    ddp_supp_trade_profile_rec.create_claim_price_increase := p3_a23;
    ddp_supp_trade_profile_rec.skip_approval_flag := p3_a24;
    ddp_supp_trade_profile_rec.skip_adjustment_flag := p3_a25;
    ddp_supp_trade_profile_rec.settlement_method_supplier_inc := p3_a26;
    ddp_supp_trade_profile_rec.settlement_method_supplier_dec := p3_a27;
    ddp_supp_trade_profile_rec.settlement_method_customer := p3_a28;
    ddp_supp_trade_profile_rec.authorization_period := p3_a29;
    ddp_supp_trade_profile_rec.grace_days := p3_a30;
    ddp_supp_trade_profile_rec.allow_qty_increase := p3_a31;
    ddp_supp_trade_profile_rec.qty_increase_tolerance := p3_a32;
    ddp_supp_trade_profile_rec.request_communication := p3_a33;
    ddp_supp_trade_profile_rec.claim_communication := p3_a34;
    ddp_supp_trade_profile_rec.claim_frequency := p3_a35;
    ddp_supp_trade_profile_rec.claim_frequency_unit := p3_a36;
    ddp_supp_trade_profile_rec.claim_computation_basis := p3_a37;
    ddp_supp_trade_profile_rec.attribute_category := p3_a38;
    ddp_supp_trade_profile_rec.attribute1 := p3_a39;
    ddp_supp_trade_profile_rec.attribute2 := p3_a40;
    ddp_supp_trade_profile_rec.attribute3 := p3_a41;
    ddp_supp_trade_profile_rec.attribute4 := p3_a42;
    ddp_supp_trade_profile_rec.attribute5 := p3_a43;
    ddp_supp_trade_profile_rec.attribute6 := p3_a44;
    ddp_supp_trade_profile_rec.attribute7 := p3_a45;
    ddp_supp_trade_profile_rec.attribute8 := p3_a46;
    ddp_supp_trade_profile_rec.attribute9 := p3_a47;
    ddp_supp_trade_profile_rec.attribute10 := p3_a48;
    ddp_supp_trade_profile_rec.attribute11 := p3_a49;
    ddp_supp_trade_profile_rec.attribute12 := p3_a50;
    ddp_supp_trade_profile_rec.attribute13 := p3_a51;
    ddp_supp_trade_profile_rec.attribute14 := p3_a52;
    ddp_supp_trade_profile_rec.attribute15 := p3_a53;
    ddp_supp_trade_profile_rec.attribute16 := p3_a54;
    ddp_supp_trade_profile_rec.attribute17 := p3_a55;
    ddp_supp_trade_profile_rec.attribute18 := p3_a56;
    ddp_supp_trade_profile_rec.attribute19 := p3_a57;
    ddp_supp_trade_profile_rec.attribute20 := p3_a58;
    ddp_supp_trade_profile_rec.attribute21 := p3_a59;
    ddp_supp_trade_profile_rec.attribute22 := p3_a60;
    ddp_supp_trade_profile_rec.attribute23 := p3_a61;
    ddp_supp_trade_profile_rec.attribute24 := p3_a62;
    ddp_supp_trade_profile_rec.attribute25 := p3_a63;
    ddp_supp_trade_profile_rec.attribute26 := p3_a64;
    ddp_supp_trade_profile_rec.attribute27 := p3_a65;
    ddp_supp_trade_profile_rec.attribute28 := p3_a66;
    ddp_supp_trade_profile_rec.attribute29 := p3_a67;
    ddp_supp_trade_profile_rec.attribute30 := p3_a68;
    ddp_supp_trade_profile_rec.dpp_attribute_category := p3_a69;
    ddp_supp_trade_profile_rec.dpp_attribute1 := p3_a70;
    ddp_supp_trade_profile_rec.dpp_attribute2 := p3_a71;
    ddp_supp_trade_profile_rec.dpp_attribute3 := p3_a72;
    ddp_supp_trade_profile_rec.dpp_attribute4 := p3_a73;
    ddp_supp_trade_profile_rec.dpp_attribute5 := p3_a74;
    ddp_supp_trade_profile_rec.dpp_attribute6 := p3_a75;
    ddp_supp_trade_profile_rec.dpp_attribute7 := p3_a76;
    ddp_supp_trade_profile_rec.dpp_attribute8 := p3_a77;
    ddp_supp_trade_profile_rec.dpp_attribute9 := p3_a78;
    ddp_supp_trade_profile_rec.dpp_attribute10 := p3_a79;
    ddp_supp_trade_profile_rec.dpp_attribute11 := p3_a80;
    ddp_supp_trade_profile_rec.dpp_attribute12 := p3_a81;
    ddp_supp_trade_profile_rec.dpp_attribute13 := p3_a82;
    ddp_supp_trade_profile_rec.dpp_attribute14 := p3_a83;
    ddp_supp_trade_profile_rec.dpp_attribute15 := p3_a84;
    ddp_supp_trade_profile_rec.dpp_attribute16 := p3_a85;
    ddp_supp_trade_profile_rec.dpp_attribute17 := p3_a86;
    ddp_supp_trade_profile_rec.dpp_attribute18 := p3_a87;
    ddp_supp_trade_profile_rec.dpp_attribute19 := p3_a88;
    ddp_supp_trade_profile_rec.dpp_attribute20 := p3_a89;
    ddp_supp_trade_profile_rec.dpp_attribute21 := p3_a90;
    ddp_supp_trade_profile_rec.dpp_attribute22 := p3_a91;
    ddp_supp_trade_profile_rec.dpp_attribute23 := p3_a92;
    ddp_supp_trade_profile_rec.dpp_attribute24 := p3_a93;
    ddp_supp_trade_profile_rec.dpp_attribute25 := p3_a94;
    ddp_supp_trade_profile_rec.dpp_attribute26 := p3_a95;
    ddp_supp_trade_profile_rec.dpp_attribute27 := p3_a96;
    ddp_supp_trade_profile_rec.dpp_attribute28 := p3_a97;
    ddp_supp_trade_profile_rec.dpp_attribute29 := p3_a98;
    ddp_supp_trade_profile_rec.dpp_attribute30 := p3_a99;
    ddp_supp_trade_profile_rec.org_id := p3_a100;
    ddp_supp_trade_profile_rec.security_group_id := p3_a101;
    ddp_supp_trade_profile_rec.claim_currency_code := p3_a102;
    ddp_supp_trade_profile_rec.min_claim_amt := p3_a103;
    ddp_supp_trade_profile_rec.min_claim_amt_line_lvl := p3_a104;
    ddp_supp_trade_profile_rec.auto_debit := p3_a105;
    ddp_supp_trade_profile_rec.days_before_claiming_debit := p3_a106;




    -- here's the delegated call to the old PL/SQL routine
    ozf_supp_trade_profile_pvt.validate_supp_trade_profile(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_supp_trade_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_supp_trd_prfl_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  VARCHAR2
    , p0_a32  NUMBER
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  NUMBER
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  VARCHAR2
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  VARCHAR2
    , p0_a56  VARCHAR2
    , p0_a57  VARCHAR2
    , p0_a58  VARCHAR2
    , p0_a59  VARCHAR2
    , p0_a60  VARCHAR2
    , p0_a61  VARCHAR2
    , p0_a62  VARCHAR2
    , p0_a63  VARCHAR2
    , p0_a64  VARCHAR2
    , p0_a65  VARCHAR2
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  VARCHAR2
    , p0_a71  VARCHAR2
    , p0_a72  VARCHAR2
    , p0_a73  VARCHAR2
    , p0_a74  VARCHAR2
    , p0_a75  VARCHAR2
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  VARCHAR2
    , p0_a81  VARCHAR2
    , p0_a82  VARCHAR2
    , p0_a83  VARCHAR2
    , p0_a84  VARCHAR2
    , p0_a85  VARCHAR2
    , p0_a86  VARCHAR2
    , p0_a87  VARCHAR2
    , p0_a88  VARCHAR2
    , p0_a89  VARCHAR2
    , p0_a90  VARCHAR2
    , p0_a91  VARCHAR2
    , p0_a92  VARCHAR2
    , p0_a93  VARCHAR2
    , p0_a94  VARCHAR2
    , p0_a95  VARCHAR2
    , p0_a96  VARCHAR2
    , p0_a97  VARCHAR2
    , p0_a98  VARCHAR2
    , p0_a99  VARCHAR2
    , p0_a100  NUMBER
    , p0_a101  NUMBER
    , p0_a102  VARCHAR2
    , p0_a103  NUMBER
    , p0_a104  NUMBER
    , p0_a105  VARCHAR2
    , p0_a106  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_supp_trade_profile_rec ozf_supp_trade_profile_pvt.supp_trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_supp_trade_profile_rec.supp_trade_profile_id := p0_a0;
    ddp_supp_trade_profile_rec.object_version_number := p0_a1;
    ddp_supp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_supp_trade_profile_rec.last_updated_by := p0_a3;
    ddp_supp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_supp_trade_profile_rec.created_by := p0_a5;
    ddp_supp_trade_profile_rec.last_update_login := p0_a6;
    ddp_supp_trade_profile_rec.request_id := p0_a7;
    ddp_supp_trade_profile_rec.program_application_id := p0_a8;
    ddp_supp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_supp_trade_profile_rec.program_id := p0_a10;
    ddp_supp_trade_profile_rec.created_from := p0_a11;
    ddp_supp_trade_profile_rec.supplier_id := p0_a12;
    ddp_supp_trade_profile_rec.supplier_site_id := p0_a13;
    ddp_supp_trade_profile_rec.party_id := p0_a14;
    ddp_supp_trade_profile_rec.cust_account_id := p0_a15;
    ddp_supp_trade_profile_rec.cust_acct_site_id := p0_a16;
    ddp_supp_trade_profile_rec.site_use_id := p0_a17;
    ddp_supp_trade_profile_rec.pre_approval_flag := p0_a18;
    ddp_supp_trade_profile_rec.approval_communication := p0_a19;
    ddp_supp_trade_profile_rec.gl_contra_liability_acct := p0_a20;
    ddp_supp_trade_profile_rec.gl_cost_adjustment_acct := p0_a21;
    ddp_supp_trade_profile_rec.default_days_covered := p0_a22;
    ddp_supp_trade_profile_rec.create_claim_price_increase := p0_a23;
    ddp_supp_trade_profile_rec.skip_approval_flag := p0_a24;
    ddp_supp_trade_profile_rec.skip_adjustment_flag := p0_a25;
    ddp_supp_trade_profile_rec.settlement_method_supplier_inc := p0_a26;
    ddp_supp_trade_profile_rec.settlement_method_supplier_dec := p0_a27;
    ddp_supp_trade_profile_rec.settlement_method_customer := p0_a28;
    ddp_supp_trade_profile_rec.authorization_period := p0_a29;
    ddp_supp_trade_profile_rec.grace_days := p0_a30;
    ddp_supp_trade_profile_rec.allow_qty_increase := p0_a31;
    ddp_supp_trade_profile_rec.qty_increase_tolerance := p0_a32;
    ddp_supp_trade_profile_rec.request_communication := p0_a33;
    ddp_supp_trade_profile_rec.claim_communication := p0_a34;
    ddp_supp_trade_profile_rec.claim_frequency := p0_a35;
    ddp_supp_trade_profile_rec.claim_frequency_unit := p0_a36;
    ddp_supp_trade_profile_rec.claim_computation_basis := p0_a37;
    ddp_supp_trade_profile_rec.attribute_category := p0_a38;
    ddp_supp_trade_profile_rec.attribute1 := p0_a39;
    ddp_supp_trade_profile_rec.attribute2 := p0_a40;
    ddp_supp_trade_profile_rec.attribute3 := p0_a41;
    ddp_supp_trade_profile_rec.attribute4 := p0_a42;
    ddp_supp_trade_profile_rec.attribute5 := p0_a43;
    ddp_supp_trade_profile_rec.attribute6 := p0_a44;
    ddp_supp_trade_profile_rec.attribute7 := p0_a45;
    ddp_supp_trade_profile_rec.attribute8 := p0_a46;
    ddp_supp_trade_profile_rec.attribute9 := p0_a47;
    ddp_supp_trade_profile_rec.attribute10 := p0_a48;
    ddp_supp_trade_profile_rec.attribute11 := p0_a49;
    ddp_supp_trade_profile_rec.attribute12 := p0_a50;
    ddp_supp_trade_profile_rec.attribute13 := p0_a51;
    ddp_supp_trade_profile_rec.attribute14 := p0_a52;
    ddp_supp_trade_profile_rec.attribute15 := p0_a53;
    ddp_supp_trade_profile_rec.attribute16 := p0_a54;
    ddp_supp_trade_profile_rec.attribute17 := p0_a55;
    ddp_supp_trade_profile_rec.attribute18 := p0_a56;
    ddp_supp_trade_profile_rec.attribute19 := p0_a57;
    ddp_supp_trade_profile_rec.attribute20 := p0_a58;
    ddp_supp_trade_profile_rec.attribute21 := p0_a59;
    ddp_supp_trade_profile_rec.attribute22 := p0_a60;
    ddp_supp_trade_profile_rec.attribute23 := p0_a61;
    ddp_supp_trade_profile_rec.attribute24 := p0_a62;
    ddp_supp_trade_profile_rec.attribute25 := p0_a63;
    ddp_supp_trade_profile_rec.attribute26 := p0_a64;
    ddp_supp_trade_profile_rec.attribute27 := p0_a65;
    ddp_supp_trade_profile_rec.attribute28 := p0_a66;
    ddp_supp_trade_profile_rec.attribute29 := p0_a67;
    ddp_supp_trade_profile_rec.attribute30 := p0_a68;
    ddp_supp_trade_profile_rec.dpp_attribute_category := p0_a69;
    ddp_supp_trade_profile_rec.dpp_attribute1 := p0_a70;
    ddp_supp_trade_profile_rec.dpp_attribute2 := p0_a71;
    ddp_supp_trade_profile_rec.dpp_attribute3 := p0_a72;
    ddp_supp_trade_profile_rec.dpp_attribute4 := p0_a73;
    ddp_supp_trade_profile_rec.dpp_attribute5 := p0_a74;
    ddp_supp_trade_profile_rec.dpp_attribute6 := p0_a75;
    ddp_supp_trade_profile_rec.dpp_attribute7 := p0_a76;
    ddp_supp_trade_profile_rec.dpp_attribute8 := p0_a77;
    ddp_supp_trade_profile_rec.dpp_attribute9 := p0_a78;
    ddp_supp_trade_profile_rec.dpp_attribute10 := p0_a79;
    ddp_supp_trade_profile_rec.dpp_attribute11 := p0_a80;
    ddp_supp_trade_profile_rec.dpp_attribute12 := p0_a81;
    ddp_supp_trade_profile_rec.dpp_attribute13 := p0_a82;
    ddp_supp_trade_profile_rec.dpp_attribute14 := p0_a83;
    ddp_supp_trade_profile_rec.dpp_attribute15 := p0_a84;
    ddp_supp_trade_profile_rec.dpp_attribute16 := p0_a85;
    ddp_supp_trade_profile_rec.dpp_attribute17 := p0_a86;
    ddp_supp_trade_profile_rec.dpp_attribute18 := p0_a87;
    ddp_supp_trade_profile_rec.dpp_attribute19 := p0_a88;
    ddp_supp_trade_profile_rec.dpp_attribute20 := p0_a89;
    ddp_supp_trade_profile_rec.dpp_attribute21 := p0_a90;
    ddp_supp_trade_profile_rec.dpp_attribute22 := p0_a91;
    ddp_supp_trade_profile_rec.dpp_attribute23 := p0_a92;
    ddp_supp_trade_profile_rec.dpp_attribute24 := p0_a93;
    ddp_supp_trade_profile_rec.dpp_attribute25 := p0_a94;
    ddp_supp_trade_profile_rec.dpp_attribute26 := p0_a95;
    ddp_supp_trade_profile_rec.dpp_attribute27 := p0_a96;
    ddp_supp_trade_profile_rec.dpp_attribute28 := p0_a97;
    ddp_supp_trade_profile_rec.dpp_attribute29 := p0_a98;
    ddp_supp_trade_profile_rec.dpp_attribute30 := p0_a99;
    ddp_supp_trade_profile_rec.org_id := p0_a100;
    ddp_supp_trade_profile_rec.security_group_id := p0_a101;
    ddp_supp_trade_profile_rec.claim_currency_code := p0_a102;
    ddp_supp_trade_profile_rec.min_claim_amt := p0_a103;
    ddp_supp_trade_profile_rec.min_claim_amt_line_lvl := p0_a104;
    ddp_supp_trade_profile_rec.auto_debit := p0_a105;
    ddp_supp_trade_profile_rec.days_before_claiming_debit := p0_a106;



    -- here's the delegated call to the old PL/SQL routine
    ozf_supp_trade_profile_pvt.check_supp_trd_prfl_items(ddp_supp_trade_profile_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_supp_trd_prfl_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  DATE
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  NUMBER
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  DATE
    , p5_a10  NUMBER
    , p5_a11  VARCHAR2
    , p5_a12  NUMBER
    , p5_a13  NUMBER
    , p5_a14  NUMBER
    , p5_a15  NUMBER
    , p5_a16  NUMBER
    , p5_a17  NUMBER
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  VARCHAR2
    , p5_a26  VARCHAR2
    , p5_a27  VARCHAR2
    , p5_a28  VARCHAR2
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  NUMBER
    , p5_a33  VARCHAR2
    , p5_a34  VARCHAR2
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  VARCHAR2
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  VARCHAR2
    , p5_a42  VARCHAR2
    , p5_a43  VARCHAR2
    , p5_a44  VARCHAR2
    , p5_a45  VARCHAR2
    , p5_a46  VARCHAR2
    , p5_a47  VARCHAR2
    , p5_a48  VARCHAR2
    , p5_a49  VARCHAR2
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  VARCHAR2
    , p5_a56  VARCHAR2
    , p5_a57  VARCHAR2
    , p5_a58  VARCHAR2
    , p5_a59  VARCHAR2
    , p5_a60  VARCHAR2
    , p5_a61  VARCHAR2
    , p5_a62  VARCHAR2
    , p5_a63  VARCHAR2
    , p5_a64  VARCHAR2
    , p5_a65  VARCHAR2
    , p5_a66  VARCHAR2
    , p5_a67  VARCHAR2
    , p5_a68  VARCHAR2
    , p5_a69  VARCHAR2
    , p5_a70  VARCHAR2
    , p5_a71  VARCHAR2
    , p5_a72  VARCHAR2
    , p5_a73  VARCHAR2
    , p5_a74  VARCHAR2
    , p5_a75  VARCHAR2
    , p5_a76  VARCHAR2
    , p5_a77  VARCHAR2
    , p5_a78  VARCHAR2
    , p5_a79  VARCHAR2
    , p5_a80  VARCHAR2
    , p5_a81  VARCHAR2
    , p5_a82  VARCHAR2
    , p5_a83  VARCHAR2
    , p5_a84  VARCHAR2
    , p5_a85  VARCHAR2
    , p5_a86  VARCHAR2
    , p5_a87  VARCHAR2
    , p5_a88  VARCHAR2
    , p5_a89  VARCHAR2
    , p5_a90  VARCHAR2
    , p5_a91  VARCHAR2
    , p5_a92  VARCHAR2
    , p5_a93  VARCHAR2
    , p5_a94  VARCHAR2
    , p5_a95  VARCHAR2
    , p5_a96  VARCHAR2
    , p5_a97  VARCHAR2
    , p5_a98  VARCHAR2
    , p5_a99  VARCHAR2
    , p5_a100  NUMBER
    , p5_a101  NUMBER
    , p5_a102  VARCHAR2
    , p5_a103  NUMBER
    , p5_a104  NUMBER
    , p5_a105  VARCHAR2
    , p5_a106  NUMBER
  )

  as
    ddp_supp_trade_profile_rec ozf_supp_trade_profile_pvt.supp_trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_supp_trade_profile_rec.supp_trade_profile_id := p5_a0;
    ddp_supp_trade_profile_rec.object_version_number := p5_a1;
    ddp_supp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_supp_trade_profile_rec.last_updated_by := p5_a3;
    ddp_supp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_supp_trade_profile_rec.created_by := p5_a5;
    ddp_supp_trade_profile_rec.last_update_login := p5_a6;
    ddp_supp_trade_profile_rec.request_id := p5_a7;
    ddp_supp_trade_profile_rec.program_application_id := p5_a8;
    ddp_supp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_supp_trade_profile_rec.program_id := p5_a10;
    ddp_supp_trade_profile_rec.created_from := p5_a11;
    ddp_supp_trade_profile_rec.supplier_id := p5_a12;
    ddp_supp_trade_profile_rec.supplier_site_id := p5_a13;
    ddp_supp_trade_profile_rec.party_id := p5_a14;
    ddp_supp_trade_profile_rec.cust_account_id := p5_a15;
    ddp_supp_trade_profile_rec.cust_acct_site_id := p5_a16;
    ddp_supp_trade_profile_rec.site_use_id := p5_a17;
    ddp_supp_trade_profile_rec.pre_approval_flag := p5_a18;
    ddp_supp_trade_profile_rec.approval_communication := p5_a19;
    ddp_supp_trade_profile_rec.gl_contra_liability_acct := p5_a20;
    ddp_supp_trade_profile_rec.gl_cost_adjustment_acct := p5_a21;
    ddp_supp_trade_profile_rec.default_days_covered := p5_a22;
    ddp_supp_trade_profile_rec.create_claim_price_increase := p5_a23;
    ddp_supp_trade_profile_rec.skip_approval_flag := p5_a24;
    ddp_supp_trade_profile_rec.skip_adjustment_flag := p5_a25;
    ddp_supp_trade_profile_rec.settlement_method_supplier_inc := p5_a26;
    ddp_supp_trade_profile_rec.settlement_method_supplier_dec := p5_a27;
    ddp_supp_trade_profile_rec.settlement_method_customer := p5_a28;
    ddp_supp_trade_profile_rec.authorization_period := p5_a29;
    ddp_supp_trade_profile_rec.grace_days := p5_a30;
    ddp_supp_trade_profile_rec.allow_qty_increase := p5_a31;
    ddp_supp_trade_profile_rec.qty_increase_tolerance := p5_a32;
    ddp_supp_trade_profile_rec.request_communication := p5_a33;
    ddp_supp_trade_profile_rec.claim_communication := p5_a34;
    ddp_supp_trade_profile_rec.claim_frequency := p5_a35;
    ddp_supp_trade_profile_rec.claim_frequency_unit := p5_a36;
    ddp_supp_trade_profile_rec.claim_computation_basis := p5_a37;
    ddp_supp_trade_profile_rec.attribute_category := p5_a38;
    ddp_supp_trade_profile_rec.attribute1 := p5_a39;
    ddp_supp_trade_profile_rec.attribute2 := p5_a40;
    ddp_supp_trade_profile_rec.attribute3 := p5_a41;
    ddp_supp_trade_profile_rec.attribute4 := p5_a42;
    ddp_supp_trade_profile_rec.attribute5 := p5_a43;
    ddp_supp_trade_profile_rec.attribute6 := p5_a44;
    ddp_supp_trade_profile_rec.attribute7 := p5_a45;
    ddp_supp_trade_profile_rec.attribute8 := p5_a46;
    ddp_supp_trade_profile_rec.attribute9 := p5_a47;
    ddp_supp_trade_profile_rec.attribute10 := p5_a48;
    ddp_supp_trade_profile_rec.attribute11 := p5_a49;
    ddp_supp_trade_profile_rec.attribute12 := p5_a50;
    ddp_supp_trade_profile_rec.attribute13 := p5_a51;
    ddp_supp_trade_profile_rec.attribute14 := p5_a52;
    ddp_supp_trade_profile_rec.attribute15 := p5_a53;
    ddp_supp_trade_profile_rec.attribute16 := p5_a54;
    ddp_supp_trade_profile_rec.attribute17 := p5_a55;
    ddp_supp_trade_profile_rec.attribute18 := p5_a56;
    ddp_supp_trade_profile_rec.attribute19 := p5_a57;
    ddp_supp_trade_profile_rec.attribute20 := p5_a58;
    ddp_supp_trade_profile_rec.attribute21 := p5_a59;
    ddp_supp_trade_profile_rec.attribute22 := p5_a60;
    ddp_supp_trade_profile_rec.attribute23 := p5_a61;
    ddp_supp_trade_profile_rec.attribute24 := p5_a62;
    ddp_supp_trade_profile_rec.attribute25 := p5_a63;
    ddp_supp_trade_profile_rec.attribute26 := p5_a64;
    ddp_supp_trade_profile_rec.attribute27 := p5_a65;
    ddp_supp_trade_profile_rec.attribute28 := p5_a66;
    ddp_supp_trade_profile_rec.attribute29 := p5_a67;
    ddp_supp_trade_profile_rec.attribute30 := p5_a68;
    ddp_supp_trade_profile_rec.dpp_attribute_category := p5_a69;
    ddp_supp_trade_profile_rec.dpp_attribute1 := p5_a70;
    ddp_supp_trade_profile_rec.dpp_attribute2 := p5_a71;
    ddp_supp_trade_profile_rec.dpp_attribute3 := p5_a72;
    ddp_supp_trade_profile_rec.dpp_attribute4 := p5_a73;
    ddp_supp_trade_profile_rec.dpp_attribute5 := p5_a74;
    ddp_supp_trade_profile_rec.dpp_attribute6 := p5_a75;
    ddp_supp_trade_profile_rec.dpp_attribute7 := p5_a76;
    ddp_supp_trade_profile_rec.dpp_attribute8 := p5_a77;
    ddp_supp_trade_profile_rec.dpp_attribute9 := p5_a78;
    ddp_supp_trade_profile_rec.dpp_attribute10 := p5_a79;
    ddp_supp_trade_profile_rec.dpp_attribute11 := p5_a80;
    ddp_supp_trade_profile_rec.dpp_attribute12 := p5_a81;
    ddp_supp_trade_profile_rec.dpp_attribute13 := p5_a82;
    ddp_supp_trade_profile_rec.dpp_attribute14 := p5_a83;
    ddp_supp_trade_profile_rec.dpp_attribute15 := p5_a84;
    ddp_supp_trade_profile_rec.dpp_attribute16 := p5_a85;
    ddp_supp_trade_profile_rec.dpp_attribute17 := p5_a86;
    ddp_supp_trade_profile_rec.dpp_attribute18 := p5_a87;
    ddp_supp_trade_profile_rec.dpp_attribute19 := p5_a88;
    ddp_supp_trade_profile_rec.dpp_attribute20 := p5_a89;
    ddp_supp_trade_profile_rec.dpp_attribute21 := p5_a90;
    ddp_supp_trade_profile_rec.dpp_attribute22 := p5_a91;
    ddp_supp_trade_profile_rec.dpp_attribute23 := p5_a92;
    ddp_supp_trade_profile_rec.dpp_attribute24 := p5_a93;
    ddp_supp_trade_profile_rec.dpp_attribute25 := p5_a94;
    ddp_supp_trade_profile_rec.dpp_attribute26 := p5_a95;
    ddp_supp_trade_profile_rec.dpp_attribute27 := p5_a96;
    ddp_supp_trade_profile_rec.dpp_attribute28 := p5_a97;
    ddp_supp_trade_profile_rec.dpp_attribute29 := p5_a98;
    ddp_supp_trade_profile_rec.dpp_attribute30 := p5_a99;
    ddp_supp_trade_profile_rec.org_id := p5_a100;
    ddp_supp_trade_profile_rec.security_group_id := p5_a101;
    ddp_supp_trade_profile_rec.claim_currency_code := p5_a102;
    ddp_supp_trade_profile_rec.min_claim_amt := p5_a103;
    ddp_supp_trade_profile_rec.min_claim_amt_line_lvl := p5_a104;
    ddp_supp_trade_profile_rec.auto_debit := p5_a105;
    ddp_supp_trade_profile_rec.days_before_claiming_debit := p5_a106;

    -- here's the delegated call to the old PL/SQL routine
    ozf_supp_trade_profile_pvt.validate_supp_trd_prfl_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_supp_trade_profile_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ozf_supp_trade_profile_pvt_w;

/
