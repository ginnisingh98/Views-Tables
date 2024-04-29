--------------------------------------------------------
--  DDL for Package Body OZF_TRADE_PROFILE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TRADE_PROFILE_PVT_W" as
  /* $Header: ozfwctpb.pls 120.1 2008/03/04 06:22:05 nirprasa ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_trade_profile_pvt.trade_profile_tbl_type, a0 JTF_NUMBER_TABLE
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
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
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
    , a46 JTF_NUMBER_TABLE
    , a47 JTF_NUMBER_TABLE
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_NUMBER_TABLE
    , a50 JTF_VARCHAR2_TABLE_100
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_NUMBER_TABLE
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_NUMBER_TABLE
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).trade_profile_id := a0(indx);
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
          t(ddindx).party_id := a12(indx);
          t(ddindx).site_use_id := a13(indx);
          t(ddindx).autopay_flag := a14(indx);
          t(ddindx).claim_threshold := a15(indx);
          t(ddindx).claim_currency := a16(indx);
          t(ddindx).print_flag := a17(indx);
          t(ddindx).internet_deal_view_flag := a18(indx);
          t(ddindx).internet_claims_flag := a19(indx);
          t(ddindx).autopay_periodicity := a20(indx);
          t(ddindx).autopay_periodicity_type := a21(indx);
          t(ddindx).payment_method := a22(indx);
          t(ddindx).discount_type := a23(indx);
          t(ddindx).cust_account_id := a24(indx);
          t(ddindx).cust_acct_site_id := a25(indx);
          t(ddindx).vendor_id := a26(indx);
          t(ddindx).vendor_site_id := a27(indx);
          t(ddindx).vendor_site_code := a28(indx);
          t(ddindx).context := a29(indx);
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
          t(ddindx).org_id := a46(indx);
          t(ddindx).days_due := a47(indx);
          t(ddindx).pos_write_off_threshold := a48(indx);
          t(ddindx).neg_write_off_threshold := a49(indx);
          t(ddindx).un_earned_pay_allow_to := a50(indx);
          t(ddindx).un_earned_pay_thold_type := a51(indx);
          t(ddindx).un_earned_pay_threshold := a52(indx);
          t(ddindx).un_earned_pay_thold_flag := a53(indx);
          t(ddindx).header_tolerance_calc_code := a54(indx);
          t(ddindx).header_tolerance_operand := a55(indx);
          t(ddindx).line_tolerance_calc_code := a56(indx);
          t(ddindx).line_tolerance_operand := a57(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_trade_profile_pvt.trade_profile_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
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
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a46 out nocopy JTF_NUMBER_TABLE
    , a47 out nocopy JTF_NUMBER_TABLE
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_NUMBER_TABLE
    , a50 out nocopy JTF_VARCHAR2_TABLE_100
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_NUMBER_TABLE
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_VARCHAR2_TABLE_100
    , a55 out nocopy JTF_NUMBER_TABLE
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
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
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_100();
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
    a46 := JTF_NUMBER_TABLE();
    a47 := JTF_NUMBER_TABLE();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_NUMBER_TABLE();
    a50 := JTF_VARCHAR2_TABLE_100();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_NUMBER_TABLE();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_NUMBER_TABLE();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
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
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_100();
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
      a46 := JTF_NUMBER_TABLE();
      a47 := JTF_NUMBER_TABLE();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_NUMBER_TABLE();
      a50 := JTF_VARCHAR2_TABLE_100();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_NUMBER_TABLE();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_NUMBER_TABLE();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).trade_profile_id;
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
          a12(indx) := t(ddindx).party_id;
          a13(indx) := t(ddindx).site_use_id;
          a14(indx) := t(ddindx).autopay_flag;
          a15(indx) := t(ddindx).claim_threshold;
          a16(indx) := t(ddindx).claim_currency;
          a17(indx) := t(ddindx).print_flag;
          a18(indx) := t(ddindx).internet_deal_view_flag;
          a19(indx) := t(ddindx).internet_claims_flag;
          a20(indx) := t(ddindx).autopay_periodicity;
          a21(indx) := t(ddindx).autopay_periodicity_type;
          a22(indx) := t(ddindx).payment_method;
          a23(indx) := t(ddindx).discount_type;
          a24(indx) := t(ddindx).cust_account_id;
          a25(indx) := t(ddindx).cust_acct_site_id;
          a26(indx) := t(ddindx).vendor_id;
          a27(indx) := t(ddindx).vendor_site_id;
          a28(indx) := t(ddindx).vendor_site_code;
          a29(indx) := t(ddindx).context;
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
          a46(indx) := t(ddindx).org_id;
          a47(indx) := t(ddindx).days_due;
          a48(indx) := t(ddindx).pos_write_off_threshold;
          a49(indx) := t(ddindx).neg_write_off_threshold;
          a50(indx) := t(ddindx).un_earned_pay_allow_to;
          a51(indx) := t(ddindx).un_earned_pay_thold_type;
          a52(indx) := t(ddindx).un_earned_pay_threshold;
          a53(indx) := t(ddindx).un_earned_pay_thold_flag;
          a54(indx) := t(ddindx).header_tolerance_calc_code;
          a55(indx) := t(ddindx).header_tolerance_operand;
          a56(indx) := t(ddindx).line_tolerance_calc_code;
          a57(indx) := t(ddindx).line_tolerance_operand;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_trade_profile(p_api_version_number  NUMBER
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
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
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
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  NUMBER
    , x_trade_profile_id out nocopy  NUMBER
  )

  as
    ddp_trade_profile_rec ozf_trade_profile_pvt.trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_trade_profile_rec.trade_profile_id := p7_a0;
    ddp_trade_profile_rec.object_version_number := p7_a1;
    ddp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_trade_profile_rec.last_updated_by := p7_a3;
    ddp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_trade_profile_rec.created_by := p7_a5;
    ddp_trade_profile_rec.last_update_login := p7_a6;
    ddp_trade_profile_rec.request_id := p7_a7;
    ddp_trade_profile_rec.program_application_id := p7_a8;
    ddp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_trade_profile_rec.program_id := p7_a10;
    ddp_trade_profile_rec.created_from := p7_a11;
    ddp_trade_profile_rec.party_id := p7_a12;
    ddp_trade_profile_rec.site_use_id := p7_a13;
    ddp_trade_profile_rec.autopay_flag := p7_a14;
    ddp_trade_profile_rec.claim_threshold := p7_a15;
    ddp_trade_profile_rec.claim_currency := p7_a16;
    ddp_trade_profile_rec.print_flag := p7_a17;
    ddp_trade_profile_rec.internet_deal_view_flag := p7_a18;
    ddp_trade_profile_rec.internet_claims_flag := p7_a19;
    ddp_trade_profile_rec.autopay_periodicity := p7_a20;
    ddp_trade_profile_rec.autopay_periodicity_type := p7_a21;
    ddp_trade_profile_rec.payment_method := p7_a22;
    ddp_trade_profile_rec.discount_type := p7_a23;
    ddp_trade_profile_rec.cust_account_id := p7_a24;
    ddp_trade_profile_rec.cust_acct_site_id := p7_a25;
    ddp_trade_profile_rec.vendor_id := p7_a26;
    ddp_trade_profile_rec.vendor_site_id := p7_a27;
    ddp_trade_profile_rec.vendor_site_code := p7_a28;
    ddp_trade_profile_rec.context := p7_a29;
    ddp_trade_profile_rec.attribute_category := p7_a30;
    ddp_trade_profile_rec.attribute1 := p7_a31;
    ddp_trade_profile_rec.attribute2 := p7_a32;
    ddp_trade_profile_rec.attribute3 := p7_a33;
    ddp_trade_profile_rec.attribute4 := p7_a34;
    ddp_trade_profile_rec.attribute5 := p7_a35;
    ddp_trade_profile_rec.attribute6 := p7_a36;
    ddp_trade_profile_rec.attribute7 := p7_a37;
    ddp_trade_profile_rec.attribute8 := p7_a38;
    ddp_trade_profile_rec.attribute9 := p7_a39;
    ddp_trade_profile_rec.attribute10 := p7_a40;
    ddp_trade_profile_rec.attribute11 := p7_a41;
    ddp_trade_profile_rec.attribute12 := p7_a42;
    ddp_trade_profile_rec.attribute13 := p7_a43;
    ddp_trade_profile_rec.attribute14 := p7_a44;
    ddp_trade_profile_rec.attribute15 := p7_a45;
    ddp_trade_profile_rec.org_id := p7_a46;
    ddp_trade_profile_rec.days_due := p7_a47;
    ddp_trade_profile_rec.pos_write_off_threshold := p7_a48;
    ddp_trade_profile_rec.neg_write_off_threshold := p7_a49;
    ddp_trade_profile_rec.un_earned_pay_allow_to := p7_a50;
    ddp_trade_profile_rec.un_earned_pay_thold_type := p7_a51;
    ddp_trade_profile_rec.un_earned_pay_threshold := p7_a52;
    ddp_trade_profile_rec.un_earned_pay_thold_flag := p7_a53;
    ddp_trade_profile_rec.header_tolerance_calc_code := p7_a54;
    ddp_trade_profile_rec.header_tolerance_operand := p7_a55;
    ddp_trade_profile_rec.line_tolerance_calc_code := p7_a56;
    ddp_trade_profile_rec.line_tolerance_operand := p7_a57;


    -- here's the delegated call to the old PL/SQL routine
    ozf_trade_profile_pvt.create_trade_profile(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trade_profile_rec,
      x_trade_profile_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_trade_profile(p_api_version_number  NUMBER
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
    , p7_a14  VARCHAR2
    , p7_a15  NUMBER
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  NUMBER
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
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
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  VARCHAR2
    , p7_a45  VARCHAR2
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p7_a48  NUMBER
    , p7_a49  NUMBER
    , p7_a50  VARCHAR2
    , p7_a51  VARCHAR2
    , p7_a52  NUMBER
    , p7_a53  VARCHAR2
    , p7_a54  VARCHAR2
    , p7_a55  NUMBER
    , p7_a56  VARCHAR2
    , p7_a57  NUMBER
    , x_object_version_number out nocopy  NUMBER
  )

  as
    ddp_trade_profile_rec ozf_trade_profile_pvt.trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_trade_profile_rec.trade_profile_id := p7_a0;
    ddp_trade_profile_rec.object_version_number := p7_a1;
    ddp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_trade_profile_rec.last_updated_by := p7_a3;
    ddp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_trade_profile_rec.created_by := p7_a5;
    ddp_trade_profile_rec.last_update_login := p7_a6;
    ddp_trade_profile_rec.request_id := p7_a7;
    ddp_trade_profile_rec.program_application_id := p7_a8;
    ddp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_trade_profile_rec.program_id := p7_a10;
    ddp_trade_profile_rec.created_from := p7_a11;
    ddp_trade_profile_rec.party_id := p7_a12;
    ddp_trade_profile_rec.site_use_id := p7_a13;
    ddp_trade_profile_rec.autopay_flag := p7_a14;
    ddp_trade_profile_rec.claim_threshold := p7_a15;
    ddp_trade_profile_rec.claim_currency := p7_a16;
    ddp_trade_profile_rec.print_flag := p7_a17;
    ddp_trade_profile_rec.internet_deal_view_flag := p7_a18;
    ddp_trade_profile_rec.internet_claims_flag := p7_a19;
    ddp_trade_profile_rec.autopay_periodicity := p7_a20;
    ddp_trade_profile_rec.autopay_periodicity_type := p7_a21;
    ddp_trade_profile_rec.payment_method := p7_a22;
    ddp_trade_profile_rec.discount_type := p7_a23;
    ddp_trade_profile_rec.cust_account_id := p7_a24;
    ddp_trade_profile_rec.cust_acct_site_id := p7_a25;
    ddp_trade_profile_rec.vendor_id := p7_a26;
    ddp_trade_profile_rec.vendor_site_id := p7_a27;
    ddp_trade_profile_rec.vendor_site_code := p7_a28;
    ddp_trade_profile_rec.context := p7_a29;
    ddp_trade_profile_rec.attribute_category := p7_a30;
    ddp_trade_profile_rec.attribute1 := p7_a31;
    ddp_trade_profile_rec.attribute2 := p7_a32;
    ddp_trade_profile_rec.attribute3 := p7_a33;
    ddp_trade_profile_rec.attribute4 := p7_a34;
    ddp_trade_profile_rec.attribute5 := p7_a35;
    ddp_trade_profile_rec.attribute6 := p7_a36;
    ddp_trade_profile_rec.attribute7 := p7_a37;
    ddp_trade_profile_rec.attribute8 := p7_a38;
    ddp_trade_profile_rec.attribute9 := p7_a39;
    ddp_trade_profile_rec.attribute10 := p7_a40;
    ddp_trade_profile_rec.attribute11 := p7_a41;
    ddp_trade_profile_rec.attribute12 := p7_a42;
    ddp_trade_profile_rec.attribute13 := p7_a43;
    ddp_trade_profile_rec.attribute14 := p7_a44;
    ddp_trade_profile_rec.attribute15 := p7_a45;
    ddp_trade_profile_rec.org_id := p7_a46;
    ddp_trade_profile_rec.days_due := p7_a47;
    ddp_trade_profile_rec.pos_write_off_threshold := p7_a48;
    ddp_trade_profile_rec.neg_write_off_threshold := p7_a49;
    ddp_trade_profile_rec.un_earned_pay_allow_to := p7_a50;
    ddp_trade_profile_rec.un_earned_pay_thold_type := p7_a51;
    ddp_trade_profile_rec.un_earned_pay_threshold := p7_a52;
    ddp_trade_profile_rec.un_earned_pay_thold_flag := p7_a53;
    ddp_trade_profile_rec.header_tolerance_calc_code := p7_a54;
    ddp_trade_profile_rec.header_tolerance_operand := p7_a55;
    ddp_trade_profile_rec.line_tolerance_calc_code := p7_a56;
    ddp_trade_profile_rec.line_tolerance_operand := p7_a57;


    -- here's the delegated call to the old PL/SQL routine
    ozf_trade_profile_pvt.update_trade_profile(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trade_profile_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_trade_profile(p_api_version_number  NUMBER
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
    , p3_a14  VARCHAR2
    , p3_a15  NUMBER
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  NUMBER
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  NUMBER
    , p3_a28  VARCHAR2
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
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  NUMBER
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  NUMBER
    , p3_a56  VARCHAR2
    , p3_a57  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_trade_profile_rec ozf_trade_profile_pvt.trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_trade_profile_rec.trade_profile_id := p3_a0;
    ddp_trade_profile_rec.object_version_number := p3_a1;
    ddp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_trade_profile_rec.last_updated_by := p3_a3;
    ddp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_trade_profile_rec.created_by := p3_a5;
    ddp_trade_profile_rec.last_update_login := p3_a6;
    ddp_trade_profile_rec.request_id := p3_a7;
    ddp_trade_profile_rec.program_application_id := p3_a8;
    ddp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a9);
    ddp_trade_profile_rec.program_id := p3_a10;
    ddp_trade_profile_rec.created_from := p3_a11;
    ddp_trade_profile_rec.party_id := p3_a12;
    ddp_trade_profile_rec.site_use_id := p3_a13;
    ddp_trade_profile_rec.autopay_flag := p3_a14;
    ddp_trade_profile_rec.claim_threshold := p3_a15;
    ddp_trade_profile_rec.claim_currency := p3_a16;
    ddp_trade_profile_rec.print_flag := p3_a17;
    ddp_trade_profile_rec.internet_deal_view_flag := p3_a18;
    ddp_trade_profile_rec.internet_claims_flag := p3_a19;
    ddp_trade_profile_rec.autopay_periodicity := p3_a20;
    ddp_trade_profile_rec.autopay_periodicity_type := p3_a21;
    ddp_trade_profile_rec.payment_method := p3_a22;
    ddp_trade_profile_rec.discount_type := p3_a23;
    ddp_trade_profile_rec.cust_account_id := p3_a24;
    ddp_trade_profile_rec.cust_acct_site_id := p3_a25;
    ddp_trade_profile_rec.vendor_id := p3_a26;
    ddp_trade_profile_rec.vendor_site_id := p3_a27;
    ddp_trade_profile_rec.vendor_site_code := p3_a28;
    ddp_trade_profile_rec.context := p3_a29;
    ddp_trade_profile_rec.attribute_category := p3_a30;
    ddp_trade_profile_rec.attribute1 := p3_a31;
    ddp_trade_profile_rec.attribute2 := p3_a32;
    ddp_trade_profile_rec.attribute3 := p3_a33;
    ddp_trade_profile_rec.attribute4 := p3_a34;
    ddp_trade_profile_rec.attribute5 := p3_a35;
    ddp_trade_profile_rec.attribute6 := p3_a36;
    ddp_trade_profile_rec.attribute7 := p3_a37;
    ddp_trade_profile_rec.attribute8 := p3_a38;
    ddp_trade_profile_rec.attribute9 := p3_a39;
    ddp_trade_profile_rec.attribute10 := p3_a40;
    ddp_trade_profile_rec.attribute11 := p3_a41;
    ddp_trade_profile_rec.attribute12 := p3_a42;
    ddp_trade_profile_rec.attribute13 := p3_a43;
    ddp_trade_profile_rec.attribute14 := p3_a44;
    ddp_trade_profile_rec.attribute15 := p3_a45;
    ddp_trade_profile_rec.org_id := p3_a46;
    ddp_trade_profile_rec.days_due := p3_a47;
    ddp_trade_profile_rec.pos_write_off_threshold := p3_a48;
    ddp_trade_profile_rec.neg_write_off_threshold := p3_a49;
    ddp_trade_profile_rec.un_earned_pay_allow_to := p3_a50;
    ddp_trade_profile_rec.un_earned_pay_thold_type := p3_a51;
    ddp_trade_profile_rec.un_earned_pay_threshold := p3_a52;
    ddp_trade_profile_rec.un_earned_pay_thold_flag := p3_a53;
    ddp_trade_profile_rec.header_tolerance_calc_code := p3_a54;
    ddp_trade_profile_rec.header_tolerance_operand := p3_a55;
    ddp_trade_profile_rec.line_tolerance_calc_code := p3_a56;
    ddp_trade_profile_rec.line_tolerance_operand := p3_a57;




    -- here's the delegated call to the old PL/SQL routine
    ozf_trade_profile_pvt.validate_trade_profile(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_trade_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_trade_profile_items(p0_a0  NUMBER
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
    , p0_a14  VARCHAR2
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  NUMBER
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
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
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  NUMBER
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  NUMBER
    , p0_a53  VARCHAR2
    , p0_a54  VARCHAR2
    , p0_a55  NUMBER
    , p0_a56  VARCHAR2
    , p0_a57  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_trade_profile_rec ozf_trade_profile_pvt.trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_trade_profile_rec.trade_profile_id := p0_a0;
    ddp_trade_profile_rec.object_version_number := p0_a1;
    ddp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_trade_profile_rec.last_updated_by := p0_a3;
    ddp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_trade_profile_rec.created_by := p0_a5;
    ddp_trade_profile_rec.last_update_login := p0_a6;
    ddp_trade_profile_rec.request_id := p0_a7;
    ddp_trade_profile_rec.program_application_id := p0_a8;
    ddp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_trade_profile_rec.program_id := p0_a10;
    ddp_trade_profile_rec.created_from := p0_a11;
    ddp_trade_profile_rec.party_id := p0_a12;
    ddp_trade_profile_rec.site_use_id := p0_a13;
    ddp_trade_profile_rec.autopay_flag := p0_a14;
    ddp_trade_profile_rec.claim_threshold := p0_a15;
    ddp_trade_profile_rec.claim_currency := p0_a16;
    ddp_trade_profile_rec.print_flag := p0_a17;
    ddp_trade_profile_rec.internet_deal_view_flag := p0_a18;
    ddp_trade_profile_rec.internet_claims_flag := p0_a19;
    ddp_trade_profile_rec.autopay_periodicity := p0_a20;
    ddp_trade_profile_rec.autopay_periodicity_type := p0_a21;
    ddp_trade_profile_rec.payment_method := p0_a22;
    ddp_trade_profile_rec.discount_type := p0_a23;
    ddp_trade_profile_rec.cust_account_id := p0_a24;
    ddp_trade_profile_rec.cust_acct_site_id := p0_a25;
    ddp_trade_profile_rec.vendor_id := p0_a26;
    ddp_trade_profile_rec.vendor_site_id := p0_a27;
    ddp_trade_profile_rec.vendor_site_code := p0_a28;
    ddp_trade_profile_rec.context := p0_a29;
    ddp_trade_profile_rec.attribute_category := p0_a30;
    ddp_trade_profile_rec.attribute1 := p0_a31;
    ddp_trade_profile_rec.attribute2 := p0_a32;
    ddp_trade_profile_rec.attribute3 := p0_a33;
    ddp_trade_profile_rec.attribute4 := p0_a34;
    ddp_trade_profile_rec.attribute5 := p0_a35;
    ddp_trade_profile_rec.attribute6 := p0_a36;
    ddp_trade_profile_rec.attribute7 := p0_a37;
    ddp_trade_profile_rec.attribute8 := p0_a38;
    ddp_trade_profile_rec.attribute9 := p0_a39;
    ddp_trade_profile_rec.attribute10 := p0_a40;
    ddp_trade_profile_rec.attribute11 := p0_a41;
    ddp_trade_profile_rec.attribute12 := p0_a42;
    ddp_trade_profile_rec.attribute13 := p0_a43;
    ddp_trade_profile_rec.attribute14 := p0_a44;
    ddp_trade_profile_rec.attribute15 := p0_a45;
    ddp_trade_profile_rec.org_id := p0_a46;
    ddp_trade_profile_rec.days_due := p0_a47;
    ddp_trade_profile_rec.pos_write_off_threshold := p0_a48;
    ddp_trade_profile_rec.neg_write_off_threshold := p0_a49;
    ddp_trade_profile_rec.un_earned_pay_allow_to := p0_a50;
    ddp_trade_profile_rec.un_earned_pay_thold_type := p0_a51;
    ddp_trade_profile_rec.un_earned_pay_threshold := p0_a52;
    ddp_trade_profile_rec.un_earned_pay_thold_flag := p0_a53;
    ddp_trade_profile_rec.header_tolerance_calc_code := p0_a54;
    ddp_trade_profile_rec.header_tolerance_operand := p0_a55;
    ddp_trade_profile_rec.line_tolerance_calc_code := p0_a56;
    ddp_trade_profile_rec.line_tolerance_operand := p0_a57;



    -- here's the delegated call to the old PL/SQL routine
    ozf_trade_profile_pvt.check_trade_profile_items(ddp_trade_profile_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_trade_profile_rec(p_api_version_number  NUMBER
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
    , p5_a14  VARCHAR2
    , p5_a15  NUMBER
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  NUMBER
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
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
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  NUMBER
    , p5_a53  VARCHAR2
    , p5_a54  VARCHAR2
    , p5_a55  NUMBER
    , p5_a56  VARCHAR2
    , p5_a57  NUMBER
  )

  as
    ddp_trade_profile_rec ozf_trade_profile_pvt.trade_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_trade_profile_rec.trade_profile_id := p5_a0;
    ddp_trade_profile_rec.object_version_number := p5_a1;
    ddp_trade_profile_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_trade_profile_rec.last_updated_by := p5_a3;
    ddp_trade_profile_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_trade_profile_rec.created_by := p5_a5;
    ddp_trade_profile_rec.last_update_login := p5_a6;
    ddp_trade_profile_rec.request_id := p5_a7;
    ddp_trade_profile_rec.program_application_id := p5_a8;
    ddp_trade_profile_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_trade_profile_rec.program_id := p5_a10;
    ddp_trade_profile_rec.created_from := p5_a11;
    ddp_trade_profile_rec.party_id := p5_a12;
    ddp_trade_profile_rec.site_use_id := p5_a13;
    ddp_trade_profile_rec.autopay_flag := p5_a14;
    ddp_trade_profile_rec.claim_threshold := p5_a15;
    ddp_trade_profile_rec.claim_currency := p5_a16;
    ddp_trade_profile_rec.print_flag := p5_a17;
    ddp_trade_profile_rec.internet_deal_view_flag := p5_a18;
    ddp_trade_profile_rec.internet_claims_flag := p5_a19;
    ddp_trade_profile_rec.autopay_periodicity := p5_a20;
    ddp_trade_profile_rec.autopay_periodicity_type := p5_a21;
    ddp_trade_profile_rec.payment_method := p5_a22;
    ddp_trade_profile_rec.discount_type := p5_a23;
    ddp_trade_profile_rec.cust_account_id := p5_a24;
    ddp_trade_profile_rec.cust_acct_site_id := p5_a25;
    ddp_trade_profile_rec.vendor_id := p5_a26;
    ddp_trade_profile_rec.vendor_site_id := p5_a27;
    ddp_trade_profile_rec.vendor_site_code := p5_a28;
    ddp_trade_profile_rec.context := p5_a29;
    ddp_trade_profile_rec.attribute_category := p5_a30;
    ddp_trade_profile_rec.attribute1 := p5_a31;
    ddp_trade_profile_rec.attribute2 := p5_a32;
    ddp_trade_profile_rec.attribute3 := p5_a33;
    ddp_trade_profile_rec.attribute4 := p5_a34;
    ddp_trade_profile_rec.attribute5 := p5_a35;
    ddp_trade_profile_rec.attribute6 := p5_a36;
    ddp_trade_profile_rec.attribute7 := p5_a37;
    ddp_trade_profile_rec.attribute8 := p5_a38;
    ddp_trade_profile_rec.attribute9 := p5_a39;
    ddp_trade_profile_rec.attribute10 := p5_a40;
    ddp_trade_profile_rec.attribute11 := p5_a41;
    ddp_trade_profile_rec.attribute12 := p5_a42;
    ddp_trade_profile_rec.attribute13 := p5_a43;
    ddp_trade_profile_rec.attribute14 := p5_a44;
    ddp_trade_profile_rec.attribute15 := p5_a45;
    ddp_trade_profile_rec.org_id := p5_a46;
    ddp_trade_profile_rec.days_due := p5_a47;
    ddp_trade_profile_rec.pos_write_off_threshold := p5_a48;
    ddp_trade_profile_rec.neg_write_off_threshold := p5_a49;
    ddp_trade_profile_rec.un_earned_pay_allow_to := p5_a50;
    ddp_trade_profile_rec.un_earned_pay_thold_type := p5_a51;
    ddp_trade_profile_rec.un_earned_pay_threshold := p5_a52;
    ddp_trade_profile_rec.un_earned_pay_thold_flag := p5_a53;
    ddp_trade_profile_rec.header_tolerance_calc_code := p5_a54;
    ddp_trade_profile_rec.header_tolerance_operand := p5_a55;
    ddp_trade_profile_rec.line_tolerance_calc_code := p5_a56;
    ddp_trade_profile_rec.line_tolerance_operand := p5_a57;

    -- here's the delegated call to the old PL/SQL routine
    ozf_trade_profile_pvt.validate_trade_profile_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_trade_profile_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ozf_trade_profile_pvt_w;

/
