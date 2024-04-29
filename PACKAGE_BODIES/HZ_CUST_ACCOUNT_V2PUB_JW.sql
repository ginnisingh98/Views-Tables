--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCOUNT_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCOUNT_V2PUB_JW" as
  /* $Header: ARH2CAJB.pls 120.7 2006/02/24 00:55:53 baianand noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_cust_account_1(p_init_msg_list  VARCHAR2
    , p_create_profile_amt  VARCHAR2
    , x_cust_account_id out nocopy  NUMBER
    , x_account_number out nocopy  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_profile_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  NUMBER := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  NUMBER := null
    , p1_a52  NUMBER := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  NUMBER := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  NUMBER := null
    , p1_a63  NUMBER := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  NUMBER := null
    , p1_a66  DATE := null
    , p1_a67  DATE := null
    , p1_a68  DATE := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  DATE := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  DATE := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  NUMBER := null
    , p1_a85  NUMBER := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  DATE := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  NUMBER := null
    , p1_a98  NUMBER := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  VARCHAR2 := null
    , p2_a9  VARCHAR2 := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  DATE := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  DATE := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  VARCHAR2 := null
    , p2_a27  VARCHAR2 := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  DATE := null
    , p2_a30  NUMBER := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  NUMBER := null
    , p2_a33  NUMBER := null
    , p2_a34  VARCHAR2 := null
    , p2_a35  VARCHAR2 := null
    , p2_a36  VARCHAR2 := null
    , p2_a37  VARCHAR2 := null
    , p2_a38  VARCHAR2 := null
    , p2_a39  VARCHAR2 := null
    , p2_a40  VARCHAR2 := null
    , p2_a41  VARCHAR2 := null
    , p2_a42  VARCHAR2 := null
    , p2_a43  VARCHAR2 := null
    , p2_a44  VARCHAR2 := null
    , p2_a45  VARCHAR2 := null
    , p2_a46  VARCHAR2 := null
    , p2_a47  VARCHAR2 := null
    , p2_a48  VARCHAR2 := null
    , p2_a49  VARCHAR2 := null
    , p2_a50  VARCHAR2 := null
    , p2_a51  VARCHAR2 := null
    , p2_a52  VARCHAR2 := null
    , p2_a53  VARCHAR2 := null
    , p2_a54  VARCHAR2 := null
    , p2_a55  VARCHAR2 := null
    , p2_a56  VARCHAR2 := null
    , p2_a57  VARCHAR2 := null
    , p2_a58  VARCHAR2 := null
    , p2_a59  VARCHAR2 := null
    , p2_a60  NUMBER := null
    , p2_a61  VARCHAR2 := null
    , p2_a62  NUMBER := null
    , p2_a63  VARCHAR2 := null
    , p2_a64  VARCHAR2 := null
    , p2_a65  VARCHAR2 := null
    , p2_a66  VARCHAR2 := null
    , p2_a67  VARCHAR2 := null
    , p2_a68  VARCHAR2 := null
    , p2_a69  VARCHAR2 := null
    , p2_a70  VARCHAR2 := null
    , p2_a71  VARCHAR2 := null
    , p2_a72  VARCHAR2 := null
    , p2_a73  VARCHAR2 := null
    , p2_a74  VARCHAR2 := null
    , p2_a75  VARCHAR2 := null
    , p2_a76  VARCHAR2 := null
    , p2_a77  VARCHAR2 := null
    , p2_a78  VARCHAR2 := null
    , p2_a79  VARCHAR2 := null
    , p2_a80  VARCHAR2 := null
    , p2_a81  VARCHAR2 := null
    , p2_a82  VARCHAR2 := null
    , p2_a83  VARCHAR2 := null
    , p2_a84  VARCHAR2 := null
    , p2_a85  VARCHAR2 := null
    , p2_a86  VARCHAR2 := null
    , p2_a87  VARCHAR2 := null
    , p2_a88  VARCHAR2 := null
    , p2_a89  VARCHAR2 := null
    , p2_a90  VARCHAR2 := null
    , p2_a91  VARCHAR2 := null
    , p2_a92  VARCHAR2 := null
    , p2_a93  VARCHAR2 := null
    , p2_a94  VARCHAR2 := null
    , p3_a0  NUMBER := null
    , p3_a1  NUMBER := null
    , p3_a2  VARCHAR2 := null
    , p3_a3  NUMBER := null
    , p3_a4  NUMBER := null
    , p3_a5  VARCHAR2 := null
    , p3_a6  DATE := null
    , p3_a7  NUMBER := null
    , p3_a8  VARCHAR2 := null
    , p3_a9  VARCHAR2 := null
    , p3_a10  VARCHAR2 := null
    , p3_a11  VARCHAR2 := null
    , p3_a12  VARCHAR2 := null
    , p3_a13  VARCHAR2 := null
    , p3_a14  NUMBER := null
    , p3_a15  NUMBER := null
    , p3_a16  VARCHAR2 := null
    , p3_a17  VARCHAR2 := null
    , p3_a18  NUMBER := null
    , p3_a19  VARCHAR2 := null
    , p3_a20  NUMBER := null
    , p3_a21  NUMBER := null
    , p3_a22  NUMBER := null
    , p3_a23  NUMBER := null
    , p3_a24  NUMBER := null
    , p3_a25  VARCHAR2 := null
    , p3_a26  NUMBER := null
    , p3_a27  NUMBER := null
    , p3_a28  VARCHAR2 := null
    , p3_a29  VARCHAR2 := null
    , p3_a30  VARCHAR2 := null
    , p3_a31  VARCHAR2 := null
    , p3_a32  VARCHAR2 := null
    , p3_a33  VARCHAR2 := null
    , p3_a34  VARCHAR2 := null
    , p3_a35  VARCHAR2 := null
    , p3_a36  VARCHAR2 := null
    , p3_a37  VARCHAR2 := null
    , p3_a38  VARCHAR2 := null
    , p3_a39  VARCHAR2 := null
    , p3_a40  VARCHAR2 := null
    , p3_a41  VARCHAR2 := null
    , p3_a42  VARCHAR2 := null
    , p3_a43  VARCHAR2 := null
    , p3_a44  VARCHAR2 := null
    , p3_a45  VARCHAR2 := null
    , p3_a46  VARCHAR2 := null
    , p3_a47  NUMBER := null
    , p3_a48  NUMBER := null
    , p3_a49  VARCHAR2 := null
    , p3_a50  VARCHAR2 := null
    , p3_a51  VARCHAR2 := null
    , p3_a52  VARCHAR2 := null
    , p3_a53  VARCHAR2 := null
    , p3_a54  VARCHAR2 := null
    , p3_a55  VARCHAR2 := null
    , p3_a56  VARCHAR2 := null
    , p3_a57  VARCHAR2 := null
    , p3_a58  VARCHAR2 := null
    , p3_a59  VARCHAR2 := null
    , p3_a60  VARCHAR2 := null
    , p3_a61  VARCHAR2 := null
    , p3_a62  VARCHAR2 := null
    , p3_a63  VARCHAR2 := null
    , p3_a64  VARCHAR2 := null
    , p3_a65  VARCHAR2 := null
    , p3_a66  VARCHAR2 := null
    , p3_a67  VARCHAR2 := null
    , p3_a68  VARCHAR2 := null
    , p3_a69  VARCHAR2 := null
    , p3_a70  VARCHAR2 := null
    , p3_a71  VARCHAR2 := null
    , p3_a72  VARCHAR2 := null
    , p3_a73  VARCHAR2 := null
    , p3_a74  VARCHAR2 := null
    , p3_a75  VARCHAR2 := null
    , p3_a76  VARCHAR2 := null
    , p3_a77  VARCHAR2 := null
    , p3_a78  VARCHAR2 := null
    , p3_a79  VARCHAR2 := null
    , p3_a80  VARCHAR2 := null
    , p3_a81  VARCHAR2 := null
    , p3_a82  VARCHAR2 := null
    , p3_a83  VARCHAR2 := null
    , p3_a84  VARCHAR2 := null
    , p3_a85  VARCHAR2 := null
    , p3_a86  VARCHAR2 := null
    , p3_a87  VARCHAR2 := null
    , p3_a88  NUMBER := null
    , p3_a89  VARCHAR2 := null
    , p3_a90  VARCHAR2 := null
    , p3_a91  NUMBER := null
    , p3_a92  VARCHAR2 := null
    , p3_a93  DATE := null
    , p3_a94  NUMBER := null
    , p3_a95  VARCHAR2 := null
    , p3_a96  VARCHAR2 := null
    , p3_a97  VARCHAR2 := null
    , p3_a98  VARCHAR2 := null
    , p3_a99  VARCHAR2 := null
    , p3_a100  VARCHAR2 := null
    , p3_a101  NUMBER := null
    , p3_a102  VARCHAR2 := null
    , p3_a103  VARCHAR2 := null
    , p3_a104  NUMBER := null
    , p3_a105  VARCHAR2 := null
    , p3_a106  DATE := null
  )
  as
    ddp_cust_account_rec hz_cust_account_v2pub.cust_account_rec_type;
    ddp_person_rec hz_party_v2pub.person_rec_type;
    ddp_customer_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_account_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_account_rec.account_number := p1_a1;
    ddp_cust_account_rec.attribute_category := p1_a2;
    ddp_cust_account_rec.attribute1 := p1_a3;
    ddp_cust_account_rec.attribute2 := p1_a4;
    ddp_cust_account_rec.attribute3 := p1_a5;
    ddp_cust_account_rec.attribute4 := p1_a6;
    ddp_cust_account_rec.attribute5 := p1_a7;
    ddp_cust_account_rec.attribute6 := p1_a8;
    ddp_cust_account_rec.attribute7 := p1_a9;
    ddp_cust_account_rec.attribute8 := p1_a10;
    ddp_cust_account_rec.attribute9 := p1_a11;
    ddp_cust_account_rec.attribute10 := p1_a12;
    ddp_cust_account_rec.attribute11 := p1_a13;
    ddp_cust_account_rec.attribute12 := p1_a14;
    ddp_cust_account_rec.attribute13 := p1_a15;
    ddp_cust_account_rec.attribute14 := p1_a16;
    ddp_cust_account_rec.attribute15 := p1_a17;
    ddp_cust_account_rec.attribute16 := p1_a18;
    ddp_cust_account_rec.attribute17 := p1_a19;
    ddp_cust_account_rec.attribute18 := p1_a20;
    ddp_cust_account_rec.attribute19 := p1_a21;
    ddp_cust_account_rec.attribute20 := p1_a22;
    ddp_cust_account_rec.global_attribute_category := p1_a23;
    ddp_cust_account_rec.global_attribute1 := p1_a24;
    ddp_cust_account_rec.global_attribute2 := p1_a25;
    ddp_cust_account_rec.global_attribute3 := p1_a26;
    ddp_cust_account_rec.global_attribute4 := p1_a27;
    ddp_cust_account_rec.global_attribute5 := p1_a28;
    ddp_cust_account_rec.global_attribute6 := p1_a29;
    ddp_cust_account_rec.global_attribute7 := p1_a30;
    ddp_cust_account_rec.global_attribute8 := p1_a31;
    ddp_cust_account_rec.global_attribute9 := p1_a32;
    ddp_cust_account_rec.global_attribute10 := p1_a33;
    ddp_cust_account_rec.global_attribute11 := p1_a34;
    ddp_cust_account_rec.global_attribute12 := p1_a35;
    ddp_cust_account_rec.global_attribute13 := p1_a36;
    ddp_cust_account_rec.global_attribute14 := p1_a37;
    ddp_cust_account_rec.global_attribute15 := p1_a38;
    ddp_cust_account_rec.global_attribute16 := p1_a39;
    ddp_cust_account_rec.global_attribute17 := p1_a40;
    ddp_cust_account_rec.global_attribute18 := p1_a41;
    ddp_cust_account_rec.global_attribute19 := p1_a42;
    ddp_cust_account_rec.global_attribute20 := p1_a43;
    ddp_cust_account_rec.orig_system_reference := p1_a44;
    ddp_cust_account_rec.orig_system := p1_a45;
    ddp_cust_account_rec.status := p1_a46;
    ddp_cust_account_rec.customer_type := p1_a47;
    ddp_cust_account_rec.customer_class_code := p1_a48;
    ddp_cust_account_rec.primary_salesrep_id := rosetta_g_miss_num_map(p1_a49);
    ddp_cust_account_rec.sales_channel_code := p1_a50;
    ddp_cust_account_rec.order_type_id := rosetta_g_miss_num_map(p1_a51);
    ddp_cust_account_rec.price_list_id := rosetta_g_miss_num_map(p1_a52);
    ddp_cust_account_rec.tax_code := p1_a53;
    ddp_cust_account_rec.fob_point := p1_a54;
    ddp_cust_account_rec.freight_term := p1_a55;
    ddp_cust_account_rec.ship_partial := p1_a56;
    ddp_cust_account_rec.ship_via := p1_a57;
    ddp_cust_account_rec.warehouse_id := rosetta_g_miss_num_map(p1_a58);
    ddp_cust_account_rec.tax_header_level_flag := p1_a59;
    ddp_cust_account_rec.tax_rounding_rule := p1_a60;
    ddp_cust_account_rec.coterminate_day_month := p1_a61;
    ddp_cust_account_rec.primary_specialist_id := rosetta_g_miss_num_map(p1_a62);
    ddp_cust_account_rec.secondary_specialist_id := rosetta_g_miss_num_map(p1_a63);
    ddp_cust_account_rec.account_liable_flag := p1_a64;
    ddp_cust_account_rec.current_balance := rosetta_g_miss_num_map(p1_a65);
    ddp_cust_account_rec.account_established_date := rosetta_g_miss_date_in_map(p1_a66);
    ddp_cust_account_rec.account_termination_date := rosetta_g_miss_date_in_map(p1_a67);
    ddp_cust_account_rec.account_activation_date := rosetta_g_miss_date_in_map(p1_a68);
    ddp_cust_account_rec.department := p1_a69;
    ddp_cust_account_rec.held_bill_expiration_date := rosetta_g_miss_date_in_map(p1_a70);
    ddp_cust_account_rec.hold_bill_flag := p1_a71;
    ddp_cust_account_rec.realtime_rate_flag := p1_a72;
    ddp_cust_account_rec.acct_life_cycle_status := p1_a73;
    ddp_cust_account_rec.account_name := p1_a74;
    ddp_cust_account_rec.deposit_refund_method := p1_a75;
    ddp_cust_account_rec.dormant_account_flag := p1_a76;
    ddp_cust_account_rec.npa_number := p1_a77;
    ddp_cust_account_rec.suspension_date := rosetta_g_miss_date_in_map(p1_a78);
    ddp_cust_account_rec.source_code := p1_a79;
    ddp_cust_account_rec.comments := p1_a80;
    ddp_cust_account_rec.dates_negative_tolerance := rosetta_g_miss_num_map(p1_a81);
    ddp_cust_account_rec.dates_positive_tolerance := rosetta_g_miss_num_map(p1_a82);
    ddp_cust_account_rec.date_type_preference := p1_a83;
    ddp_cust_account_rec.over_shipment_tolerance := rosetta_g_miss_num_map(p1_a84);
    ddp_cust_account_rec.under_shipment_tolerance := rosetta_g_miss_num_map(p1_a85);
    ddp_cust_account_rec.over_return_tolerance := rosetta_g_miss_num_map(p1_a86);
    ddp_cust_account_rec.under_return_tolerance := rosetta_g_miss_num_map(p1_a87);
    ddp_cust_account_rec.item_cross_ref_pref := p1_a88;
    ddp_cust_account_rec.ship_sets_include_lines_flag := p1_a89;
    ddp_cust_account_rec.arrivalsets_include_lines_flag := p1_a90;
    ddp_cust_account_rec.sched_date_push_flag := p1_a91;
    ddp_cust_account_rec.invoice_quantity_rule := p1_a92;
    ddp_cust_account_rec.pricing_event := p1_a93;
    ddp_cust_account_rec.status_update_date := rosetta_g_miss_date_in_map(p1_a94);
    ddp_cust_account_rec.autopay_flag := p1_a95;
    ddp_cust_account_rec.notify_flag := p1_a96;
    ddp_cust_account_rec.last_batch_id := rosetta_g_miss_num_map(p1_a97);
    ddp_cust_account_rec.selling_party_id := rosetta_g_miss_num_map(p1_a98);
    ddp_cust_account_rec.created_by_module := p1_a99;
    ddp_cust_account_rec.application_id := rosetta_g_miss_num_map(p1_a100);

    ddp_person_rec.person_pre_name_adjunct := p2_a0;
    ddp_person_rec.person_first_name := p2_a1;
    ddp_person_rec.person_middle_name := p2_a2;
    ddp_person_rec.person_last_name := p2_a3;
    ddp_person_rec.person_name_suffix := p2_a4;
    ddp_person_rec.person_title := p2_a5;
    ddp_person_rec.person_academic_title := p2_a6;
    ddp_person_rec.person_previous_last_name := p2_a7;
    ddp_person_rec.person_initials := p2_a8;
    ddp_person_rec.known_as := p2_a9;
    ddp_person_rec.known_as2 := p2_a10;
    ddp_person_rec.known_as3 := p2_a11;
    ddp_person_rec.known_as4 := p2_a12;
    ddp_person_rec.known_as5 := p2_a13;
    ddp_person_rec.person_name_phonetic := p2_a14;
    ddp_person_rec.person_first_name_phonetic := p2_a15;
    ddp_person_rec.person_last_name_phonetic := p2_a16;
    ddp_person_rec.middle_name_phonetic := p2_a17;
    ddp_person_rec.tax_reference := p2_a18;
    ddp_person_rec.jgzz_fiscal_code := p2_a19;
    ddp_person_rec.person_iden_type := p2_a20;
    ddp_person_rec.person_identifier := p2_a21;
    ddp_person_rec.date_of_birth := rosetta_g_miss_date_in_map(p2_a22);
    ddp_person_rec.place_of_birth := p2_a23;
    ddp_person_rec.date_of_death := rosetta_g_miss_date_in_map(p2_a24);
    ddp_person_rec.deceased_flag := p2_a25;
    ddp_person_rec.gender := p2_a26;
    ddp_person_rec.declared_ethnicity := p2_a27;
    ddp_person_rec.marital_status := p2_a28;
    ddp_person_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p2_a29);
    ddp_person_rec.personal_income := rosetta_g_miss_num_map(p2_a30);
    ddp_person_rec.head_of_household_flag := p2_a31;
    ddp_person_rec.household_income := rosetta_g_miss_num_map(p2_a32);
    ddp_person_rec.household_size := rosetta_g_miss_num_map(p2_a33);
    ddp_person_rec.rent_own_ind := p2_a34;
    ddp_person_rec.last_known_gps := p2_a35;
    ddp_person_rec.content_source_type := p2_a36;
    ddp_person_rec.internal_flag := p2_a37;
    ddp_person_rec.attribute_category := p2_a38;
    ddp_person_rec.attribute1 := p2_a39;
    ddp_person_rec.attribute2 := p2_a40;
    ddp_person_rec.attribute3 := p2_a41;
    ddp_person_rec.attribute4 := p2_a42;
    ddp_person_rec.attribute5 := p2_a43;
    ddp_person_rec.attribute6 := p2_a44;
    ddp_person_rec.attribute7 := p2_a45;
    ddp_person_rec.attribute8 := p2_a46;
    ddp_person_rec.attribute9 := p2_a47;
    ddp_person_rec.attribute10 := p2_a48;
    ddp_person_rec.attribute11 := p2_a49;
    ddp_person_rec.attribute12 := p2_a50;
    ddp_person_rec.attribute13 := p2_a51;
    ddp_person_rec.attribute14 := p2_a52;
    ddp_person_rec.attribute15 := p2_a53;
    ddp_person_rec.attribute16 := p2_a54;
    ddp_person_rec.attribute17 := p2_a55;
    ddp_person_rec.attribute18 := p2_a56;
    ddp_person_rec.attribute19 := p2_a57;
    ddp_person_rec.attribute20 := p2_a58;
    ddp_person_rec.created_by_module := p2_a59;
    ddp_person_rec.application_id := rosetta_g_miss_num_map(p2_a60);
    ddp_person_rec.actual_content_source := p2_a61;
    ddp_person_rec.party_rec.party_id := rosetta_g_miss_num_map(p2_a62);
    ddp_person_rec.party_rec.party_number := p2_a63;
    ddp_person_rec.party_rec.validated_flag := p2_a64;
    ddp_person_rec.party_rec.orig_system_reference := p2_a65;
    ddp_person_rec.party_rec.orig_system := p2_a66;
    ddp_person_rec.party_rec.status := p2_a67;
    ddp_person_rec.party_rec.category_code := p2_a68;
    ddp_person_rec.party_rec.salutation := p2_a69;
    ddp_person_rec.party_rec.attribute_category := p2_a70;
    ddp_person_rec.party_rec.attribute1 := p2_a71;
    ddp_person_rec.party_rec.attribute2 := p2_a72;
    ddp_person_rec.party_rec.attribute3 := p2_a73;
    ddp_person_rec.party_rec.attribute4 := p2_a74;
    ddp_person_rec.party_rec.attribute5 := p2_a75;
    ddp_person_rec.party_rec.attribute6 := p2_a76;
    ddp_person_rec.party_rec.attribute7 := p2_a77;
    ddp_person_rec.party_rec.attribute8 := p2_a78;
    ddp_person_rec.party_rec.attribute9 := p2_a79;
    ddp_person_rec.party_rec.attribute10 := p2_a80;
    ddp_person_rec.party_rec.attribute11 := p2_a81;
    ddp_person_rec.party_rec.attribute12 := p2_a82;
    ddp_person_rec.party_rec.attribute13 := p2_a83;
    ddp_person_rec.party_rec.attribute14 := p2_a84;
    ddp_person_rec.party_rec.attribute15 := p2_a85;
    ddp_person_rec.party_rec.attribute16 := p2_a86;
    ddp_person_rec.party_rec.attribute17 := p2_a87;
    ddp_person_rec.party_rec.attribute18 := p2_a88;
    ddp_person_rec.party_rec.attribute19 := p2_a89;
    ddp_person_rec.party_rec.attribute20 := p2_a90;
    ddp_person_rec.party_rec.attribute21 := p2_a91;
    ddp_person_rec.party_rec.attribute22 := p2_a92;
    ddp_person_rec.party_rec.attribute23 := p2_a93;
    ddp_person_rec.party_rec.attribute24 := p2_a94;

    ddp_customer_profile_rec.cust_account_profile_id := rosetta_g_miss_num_map(p3_a0);
    ddp_customer_profile_rec.cust_account_id := rosetta_g_miss_num_map(p3_a1);
    ddp_customer_profile_rec.status := p3_a2;
    ddp_customer_profile_rec.collector_id := rosetta_g_miss_num_map(p3_a3);
    ddp_customer_profile_rec.credit_analyst_id := rosetta_g_miss_num_map(p3_a4);
    ddp_customer_profile_rec.credit_checking := p3_a5;
    ddp_customer_profile_rec.next_credit_review_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_customer_profile_rec.tolerance := rosetta_g_miss_num_map(p3_a7);
    ddp_customer_profile_rec.discount_terms := p3_a8;
    ddp_customer_profile_rec.dunning_letters := p3_a9;
    ddp_customer_profile_rec.interest_charges := p3_a10;
    ddp_customer_profile_rec.send_statements := p3_a11;
    ddp_customer_profile_rec.credit_balance_statements := p3_a12;
    ddp_customer_profile_rec.credit_hold := p3_a13;
    ddp_customer_profile_rec.profile_class_id := rosetta_g_miss_num_map(p3_a14);
    ddp_customer_profile_rec.site_use_id := rosetta_g_miss_num_map(p3_a15);
    ddp_customer_profile_rec.credit_rating := p3_a16;
    ddp_customer_profile_rec.risk_code := p3_a17;
    ddp_customer_profile_rec.standard_terms := rosetta_g_miss_num_map(p3_a18);
    ddp_customer_profile_rec.override_terms := p3_a19;
    ddp_customer_profile_rec.dunning_letter_set_id := rosetta_g_miss_num_map(p3_a20);
    ddp_customer_profile_rec.interest_period_days := rosetta_g_miss_num_map(p3_a21);
    ddp_customer_profile_rec.payment_grace_days := rosetta_g_miss_num_map(p3_a22);
    ddp_customer_profile_rec.discount_grace_days := rosetta_g_miss_num_map(p3_a23);
    ddp_customer_profile_rec.statement_cycle_id := rosetta_g_miss_num_map(p3_a24);
    ddp_customer_profile_rec.account_status := p3_a25;
    ddp_customer_profile_rec.percent_collectable := rosetta_g_miss_num_map(p3_a26);
    ddp_customer_profile_rec.autocash_hierarchy_id := rosetta_g_miss_num_map(p3_a27);
    ddp_customer_profile_rec.attribute_category := p3_a28;
    ddp_customer_profile_rec.attribute1 := p3_a29;
    ddp_customer_profile_rec.attribute2 := p3_a30;
    ddp_customer_profile_rec.attribute3 := p3_a31;
    ddp_customer_profile_rec.attribute4 := p3_a32;
    ddp_customer_profile_rec.attribute5 := p3_a33;
    ddp_customer_profile_rec.attribute6 := p3_a34;
    ddp_customer_profile_rec.attribute7 := p3_a35;
    ddp_customer_profile_rec.attribute8 := p3_a36;
    ddp_customer_profile_rec.attribute9 := p3_a37;
    ddp_customer_profile_rec.attribute10 := p3_a38;
    ddp_customer_profile_rec.attribute11 := p3_a39;
    ddp_customer_profile_rec.attribute12 := p3_a40;
    ddp_customer_profile_rec.attribute13 := p3_a41;
    ddp_customer_profile_rec.attribute14 := p3_a42;
    ddp_customer_profile_rec.attribute15 := p3_a43;
    ddp_customer_profile_rec.auto_rec_incl_disputed_flag := p3_a44;
    ddp_customer_profile_rec.tax_printing_option := p3_a45;
    ddp_customer_profile_rec.charge_on_finance_charge_flag := p3_a46;
    ddp_customer_profile_rec.grouping_rule_id := rosetta_g_miss_num_map(p3_a47);
    ddp_customer_profile_rec.clearing_days := rosetta_g_miss_num_map(p3_a48);
    ddp_customer_profile_rec.jgzz_attribute_category := p3_a49;
    ddp_customer_profile_rec.jgzz_attribute1 := p3_a50;
    ddp_customer_profile_rec.jgzz_attribute2 := p3_a51;
    ddp_customer_profile_rec.jgzz_attribute3 := p3_a52;
    ddp_customer_profile_rec.jgzz_attribute4 := p3_a53;
    ddp_customer_profile_rec.jgzz_attribute5 := p3_a54;
    ddp_customer_profile_rec.jgzz_attribute6 := p3_a55;
    ddp_customer_profile_rec.jgzz_attribute7 := p3_a56;
    ddp_customer_profile_rec.jgzz_attribute8 := p3_a57;
    ddp_customer_profile_rec.jgzz_attribute9 := p3_a58;
    ddp_customer_profile_rec.jgzz_attribute10 := p3_a59;
    ddp_customer_profile_rec.jgzz_attribute11 := p3_a60;
    ddp_customer_profile_rec.jgzz_attribute12 := p3_a61;
    ddp_customer_profile_rec.jgzz_attribute13 := p3_a62;
    ddp_customer_profile_rec.jgzz_attribute14 := p3_a63;
    ddp_customer_profile_rec.jgzz_attribute15 := p3_a64;
    ddp_customer_profile_rec.global_attribute1 := p3_a65;
    ddp_customer_profile_rec.global_attribute2 := p3_a66;
    ddp_customer_profile_rec.global_attribute3 := p3_a67;
    ddp_customer_profile_rec.global_attribute4 := p3_a68;
    ddp_customer_profile_rec.global_attribute5 := p3_a69;
    ddp_customer_profile_rec.global_attribute6 := p3_a70;
    ddp_customer_profile_rec.global_attribute7 := p3_a71;
    ddp_customer_profile_rec.global_attribute8 := p3_a72;
    ddp_customer_profile_rec.global_attribute9 := p3_a73;
    ddp_customer_profile_rec.global_attribute10 := p3_a74;
    ddp_customer_profile_rec.global_attribute11 := p3_a75;
    ddp_customer_profile_rec.global_attribute12 := p3_a76;
    ddp_customer_profile_rec.global_attribute13 := p3_a77;
    ddp_customer_profile_rec.global_attribute14 := p3_a78;
    ddp_customer_profile_rec.global_attribute15 := p3_a79;
    ddp_customer_profile_rec.global_attribute16 := p3_a80;
    ddp_customer_profile_rec.global_attribute17 := p3_a81;
    ddp_customer_profile_rec.global_attribute18 := p3_a82;
    ddp_customer_profile_rec.global_attribute19 := p3_a83;
    ddp_customer_profile_rec.global_attribute20 := p3_a84;
    ddp_customer_profile_rec.global_attribute_category := p3_a85;
    ddp_customer_profile_rec.cons_inv_flag := p3_a86;
    ddp_customer_profile_rec.cons_inv_type := p3_a87;
    ddp_customer_profile_rec.autocash_hierarchy_id_for_adr := rosetta_g_miss_num_map(p3_a88);
    ddp_customer_profile_rec.lockbox_matching_option := p3_a89;
    ddp_customer_profile_rec.created_by_module := p3_a90;
    ddp_customer_profile_rec.application_id := rosetta_g_miss_num_map(p3_a91);
    ddp_customer_profile_rec.review_cycle := p3_a92;
    ddp_customer_profile_rec.last_credit_review_date := rosetta_g_miss_date_in_map(p3_a93);
    ddp_customer_profile_rec.party_id := rosetta_g_miss_num_map(p3_a94);
    ddp_customer_profile_rec.credit_classification := p3_a95;
    ddp_customer_profile_rec.cons_bill_level := p3_a96;
    ddp_customer_profile_rec.late_charge_calculation_trx := p3_a97;
    ddp_customer_profile_rec.credit_items_flag := p3_a98;
    ddp_customer_profile_rec.disputed_transactions_flag := p3_a99;
    ddp_customer_profile_rec.late_charge_type := p3_a100;
    ddp_customer_profile_rec.late_charge_term_id := rosetta_g_miss_num_map(p3_a101);
    ddp_customer_profile_rec.interest_calculation_period := p3_a102;
    ddp_customer_profile_rec.hold_charged_invoices_flag := p3_a103;
    ddp_customer_profile_rec.message_text_id := rosetta_g_miss_num_map(p3_a104);
    ddp_customer_profile_rec.multiple_interest_rates_flag := p3_a105;
    ddp_customer_profile_rec.charge_begin_date := rosetta_g_miss_date_in_map(p3_a106);










    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.create_cust_account(p_init_msg_list,
      ddp_cust_account_rec,
      ddp_person_rec,
      ddp_customer_profile_rec,
      p_create_profile_amt,
      x_cust_account_id,
      x_account_number,
      x_party_id,
      x_party_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any












  end;

  procedure create_cust_account_2(p_init_msg_list  VARCHAR2
    , p_create_profile_amt  VARCHAR2
    , x_cust_account_id out nocopy  NUMBER
    , x_account_number out nocopy  VARCHAR2
    , x_party_id out nocopy  NUMBER
    , x_party_number out nocopy  VARCHAR2
    , x_profile_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  NUMBER := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  NUMBER := null
    , p1_a52  NUMBER := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  NUMBER := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  NUMBER := null
    , p1_a63  NUMBER := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  NUMBER := null
    , p1_a66  DATE := null
    , p1_a67  DATE := null
    , p1_a68  DATE := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  DATE := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  DATE := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  NUMBER := null
    , p1_a85  NUMBER := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  DATE := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  NUMBER := null
    , p1_a98  NUMBER := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
    , p2_a0  VARCHAR2 := null
    , p2_a1  VARCHAR2 := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  VARCHAR2 := null
    , p2_a4  VARCHAR2 := null
    , p2_a5  VARCHAR2 := null
    , p2_a6  VARCHAR2 := null
    , p2_a7  VARCHAR2 := null
    , p2_a8  NUMBER := null
    , p2_a9  NUMBER := null
    , p2_a10  VARCHAR2 := null
    , p2_a11  VARCHAR2 := null
    , p2_a12  VARCHAR2 := null
    , p2_a13  VARCHAR2 := null
    , p2_a14  VARCHAR2 := null
    , p2_a15  VARCHAR2 := null
    , p2_a16  VARCHAR2 := null
    , p2_a17  VARCHAR2 := null
    , p2_a18  VARCHAR2 := null
    , p2_a19  VARCHAR2 := null
    , p2_a20  VARCHAR2 := null
    , p2_a21  VARCHAR2 := null
    , p2_a22  VARCHAR2 := null
    , p2_a23  VARCHAR2 := null
    , p2_a24  VARCHAR2 := null
    , p2_a25  VARCHAR2 := null
    , p2_a26  NUMBER := null
    , p2_a27  DATE := null
    , p2_a28  VARCHAR2 := null
    , p2_a29  NUMBER := null
    , p2_a30  VARCHAR2 := null
    , p2_a31  VARCHAR2 := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
    , p2_a34  VARCHAR2 := null
    , p2_a35  VARCHAR2 := null
    , p2_a36  VARCHAR2 := null
    , p2_a37  VARCHAR2 := null
    , p2_a38  VARCHAR2 := null
    , p2_a39  DATE := null
    , p2_a40  DATE := null
    , p2_a41  VARCHAR2 := null
    , p2_a42  VARCHAR2 := null
    , p2_a43  VARCHAR2 := null
    , p2_a44  VARCHAR2 := null
    , p2_a45  VARCHAR2 := null
    , p2_a46  VARCHAR2 := null
    , p2_a47  NUMBER := null
    , p2_a48  NUMBER := null
    , p2_a49  NUMBER := null
    , p2_a50  VARCHAR2 := null
    , p2_a51  VARCHAR2 := null
    , p2_a52  VARCHAR2 := null
    , p2_a53  VARCHAR2 := null
    , p2_a54  VARCHAR2 := null
    , p2_a55  VARCHAR2 := null
    , p2_a56  VARCHAR2 := null
    , p2_a57  VARCHAR2 := null
    , p2_a58  VARCHAR2 := null
    , p2_a59  VARCHAR2 := null
    , p2_a60  VARCHAR2 := null
    , p2_a61  VARCHAR2 := null
    , p2_a62  VARCHAR2 := null
    , p2_a63  VARCHAR2 := null
    , p2_a64  VARCHAR2 := null
    , p2_a65  VARCHAR2 := null
    , p2_a66  VARCHAR2 := null
    , p2_a67  VARCHAR2 := null
    , p2_a68  NUMBER := null
    , p2_a69  VARCHAR2 := null
    , p2_a70  VARCHAR2 := null
    , p2_a71  VARCHAR2 := null
    , p2_a72  VARCHAR2 := null
    , p2_a73  VARCHAR2 := null
    , p2_a74  VARCHAR2 := null
    , p2_a75  VARCHAR2 := null
    , p2_a76  VARCHAR2 := null
    , p2_a77  VARCHAR2 := null
    , p2_a78  NUMBER := null
    , p2_a79  NUMBER := null
    , p2_a80  NUMBER := null
    , p2_a81  NUMBER := null
    , p2_a82  NUMBER := null
    , p2_a83  NUMBER := null
    , p2_a84  NUMBER := null
    , p2_a85  DATE := null
    , p2_a86  VARCHAR2 := null
    , p2_a87  VARCHAR2 := null
    , p2_a88  VARCHAR2 := null
    , p2_a89  VARCHAR2 := null
    , p2_a90  VARCHAR2 := null
    , p2_a91  VARCHAR2 := null
    , p2_a92  VARCHAR2 := null
    , p2_a93  VARCHAR2 := null
    , p2_a94  VARCHAR2 := null
    , p2_a95  NUMBER := null
    , p2_a96  NUMBER := null
    , p2_a97  NUMBER := null
    , p2_a98  DATE := null
    , p2_a99  VARCHAR2 := null
    , p2_a100  VARCHAR2 := null
    , p2_a101  VARCHAR2 := null
    , p2_a102  VARCHAR2 := null
    , p2_a103  VARCHAR2 := null
    , p2_a104  VARCHAR2 := null
    , p2_a105  VARCHAR2 := null
    , p2_a106  VARCHAR2 := null
    , p2_a107  VARCHAR2 := null
    , p2_a108  NUMBER := null
    , p2_a109  VARCHAR2 := null
    , p2_a110  NUMBER := null
    , p2_a111  VARCHAR2 := null
    , p2_a112  VARCHAR2 := null
    , p2_a113  VARCHAR2 := null
    , p2_a114  VARCHAR2 := null
    , p2_a115  VARCHAR2 := null
    , p2_a116  VARCHAR2 := null
    , p2_a117  VARCHAR2 := null
    , p2_a118  VARCHAR2 := null
    , p2_a119  VARCHAR2 := null
    , p2_a120  VARCHAR2 := null
    , p2_a121  VARCHAR2 := null
    , p2_a122  VARCHAR2 := null
    , p2_a123  VARCHAR2 := null
    , p2_a124  VARCHAR2 := null
    , p2_a125  VARCHAR2 := null
    , p2_a126  VARCHAR2 := null
    , p2_a127  VARCHAR2 := null
    , p2_a128  VARCHAR2 := null
    , p2_a129  VARCHAR2 := null
    , p2_a130  VARCHAR2 := null
    , p2_a131  VARCHAR2 := null
    , p2_a132  VARCHAR2 := null
    , p2_a133  VARCHAR2 := null
    , p2_a134  VARCHAR2 := null
    , p2_a135  NUMBER := null
    , p2_a136  VARCHAR2 := null
    , p2_a137  VARCHAR2 := null
    , p2_a138  VARCHAR2 := null
    , p2_a139  NUMBER := null
    , p2_a140  VARCHAR2 := null
    , p2_a141  VARCHAR2 := null
    , p2_a142  VARCHAR2 := null
    , p2_a143  VARCHAR2 := null
    , p2_a144  VARCHAR2 := null
    , p2_a145  VARCHAR2 := null
    , p2_a146  VARCHAR2 := null
    , p2_a147  VARCHAR2 := null
    , p2_a148  VARCHAR2 := null
    , p2_a149  VARCHAR2 := null
    , p2_a150  VARCHAR2 := null
    , p2_a151  VARCHAR2 := null
    , p2_a152  VARCHAR2 := null
    , p2_a153  VARCHAR2 := null
    , p2_a154  VARCHAR2 := null
    , p2_a155  VARCHAR2 := null
    , p2_a156  VARCHAR2 := null
    , p2_a157  VARCHAR2 := null
    , p2_a158  VARCHAR2 := null
    , p2_a159  VARCHAR2 := null
    , p2_a160  VARCHAR2 := null
    , p2_a161  VARCHAR2 := null
    , p2_a162  VARCHAR2 := null
    , p2_a163  VARCHAR2 := null
    , p2_a164  VARCHAR2 := null
    , p2_a165  VARCHAR2 := null
    , p2_a166  VARCHAR2 := null
    , p2_a167  VARCHAR2 := null
    , p2_a168  VARCHAR2 := null
    , p2_a169  VARCHAR2 := null
    , p2_a170  VARCHAR2 := null
    , p2_a171  VARCHAR2 := null
    , p3_a0  NUMBER := null
    , p3_a1  NUMBER := null
    , p3_a2  VARCHAR2 := null
    , p3_a3  NUMBER := null
    , p3_a4  NUMBER := null
    , p3_a5  VARCHAR2 := null
    , p3_a6  DATE := null
    , p3_a7  NUMBER := null
    , p3_a8  VARCHAR2 := null
    , p3_a9  VARCHAR2 := null
    , p3_a10  VARCHAR2 := null
    , p3_a11  VARCHAR2 := null
    , p3_a12  VARCHAR2 := null
    , p3_a13  VARCHAR2 := null
    , p3_a14  NUMBER := null
    , p3_a15  NUMBER := null
    , p3_a16  VARCHAR2 := null
    , p3_a17  VARCHAR2 := null
    , p3_a18  NUMBER := null
    , p3_a19  VARCHAR2 := null
    , p3_a20  NUMBER := null
    , p3_a21  NUMBER := null
    , p3_a22  NUMBER := null
    , p3_a23  NUMBER := null
    , p3_a24  NUMBER := null
    , p3_a25  VARCHAR2 := null
    , p3_a26  NUMBER := null
    , p3_a27  NUMBER := null
    , p3_a28  VARCHAR2 := null
    , p3_a29  VARCHAR2 := null
    , p3_a30  VARCHAR2 := null
    , p3_a31  VARCHAR2 := null
    , p3_a32  VARCHAR2 := null
    , p3_a33  VARCHAR2 := null
    , p3_a34  VARCHAR2 := null
    , p3_a35  VARCHAR2 := null
    , p3_a36  VARCHAR2 := null
    , p3_a37  VARCHAR2 := null
    , p3_a38  VARCHAR2 := null
    , p3_a39  VARCHAR2 := null
    , p3_a40  VARCHAR2 := null
    , p3_a41  VARCHAR2 := null
    , p3_a42  VARCHAR2 := null
    , p3_a43  VARCHAR2 := null
    , p3_a44  VARCHAR2 := null
    , p3_a45  VARCHAR2 := null
    , p3_a46  VARCHAR2 := null
    , p3_a47  NUMBER := null
    , p3_a48  NUMBER := null
    , p3_a49  VARCHAR2 := null
    , p3_a50  VARCHAR2 := null
    , p3_a51  VARCHAR2 := null
    , p3_a52  VARCHAR2 := null
    , p3_a53  VARCHAR2 := null
    , p3_a54  VARCHAR2 := null
    , p3_a55  VARCHAR2 := null
    , p3_a56  VARCHAR2 := null
    , p3_a57  VARCHAR2 := null
    , p3_a58  VARCHAR2 := null
    , p3_a59  VARCHAR2 := null
    , p3_a60  VARCHAR2 := null
    , p3_a61  VARCHAR2 := null
    , p3_a62  VARCHAR2 := null
    , p3_a63  VARCHAR2 := null
    , p3_a64  VARCHAR2 := null
    , p3_a65  VARCHAR2 := null
    , p3_a66  VARCHAR2 := null
    , p3_a67  VARCHAR2 := null
    , p3_a68  VARCHAR2 := null
    , p3_a69  VARCHAR2 := null
    , p3_a70  VARCHAR2 := null
    , p3_a71  VARCHAR2 := null
    , p3_a72  VARCHAR2 := null
    , p3_a73  VARCHAR2 := null
    , p3_a74  VARCHAR2 := null
    , p3_a75  VARCHAR2 := null
    , p3_a76  VARCHAR2 := null
    , p3_a77  VARCHAR2 := null
    , p3_a78  VARCHAR2 := null
    , p3_a79  VARCHAR2 := null
    , p3_a80  VARCHAR2 := null
    , p3_a81  VARCHAR2 := null
    , p3_a82  VARCHAR2 := null
    , p3_a83  VARCHAR2 := null
    , p3_a84  VARCHAR2 := null
    , p3_a85  VARCHAR2 := null
    , p3_a86  VARCHAR2 := null
    , p3_a87  VARCHAR2 := null
    , p3_a88  NUMBER := null
    , p3_a89  VARCHAR2 := null
    , p3_a90  VARCHAR2 := null
    , p3_a91  NUMBER := null
    , p3_a92  VARCHAR2 := null
    , p3_a93  DATE := null
    , p3_a94  NUMBER := null
    , p3_a95  VARCHAR2 := null
    , p3_a96  VARCHAR2 := null
    , p3_a97  VARCHAR2 := null
    , p3_a98  VARCHAR2 := null
    , p3_a99  VARCHAR2 := null
    , p3_a100  VARCHAR2 := null
    , p3_a101  NUMBER := null
    , p3_a102  VARCHAR2 := null
    , p3_a103  VARCHAR2 := null
    , p3_a104  NUMBER := null
    , p3_a105  VARCHAR2 := null
    , p3_a106  DATE := null
  )
  as
    ddp_cust_account_rec hz_cust_account_v2pub.cust_account_rec_type;
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_customer_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_account_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_account_rec.account_number := p1_a1;
    ddp_cust_account_rec.attribute_category := p1_a2;
    ddp_cust_account_rec.attribute1 := p1_a3;
    ddp_cust_account_rec.attribute2 := p1_a4;
    ddp_cust_account_rec.attribute3 := p1_a5;
    ddp_cust_account_rec.attribute4 := p1_a6;
    ddp_cust_account_rec.attribute5 := p1_a7;
    ddp_cust_account_rec.attribute6 := p1_a8;
    ddp_cust_account_rec.attribute7 := p1_a9;
    ddp_cust_account_rec.attribute8 := p1_a10;
    ddp_cust_account_rec.attribute9 := p1_a11;
    ddp_cust_account_rec.attribute10 := p1_a12;
    ddp_cust_account_rec.attribute11 := p1_a13;
    ddp_cust_account_rec.attribute12 := p1_a14;
    ddp_cust_account_rec.attribute13 := p1_a15;
    ddp_cust_account_rec.attribute14 := p1_a16;
    ddp_cust_account_rec.attribute15 := p1_a17;
    ddp_cust_account_rec.attribute16 := p1_a18;
    ddp_cust_account_rec.attribute17 := p1_a19;
    ddp_cust_account_rec.attribute18 := p1_a20;
    ddp_cust_account_rec.attribute19 := p1_a21;
    ddp_cust_account_rec.attribute20 := p1_a22;
    ddp_cust_account_rec.global_attribute_category := p1_a23;
    ddp_cust_account_rec.global_attribute1 := p1_a24;
    ddp_cust_account_rec.global_attribute2 := p1_a25;
    ddp_cust_account_rec.global_attribute3 := p1_a26;
    ddp_cust_account_rec.global_attribute4 := p1_a27;
    ddp_cust_account_rec.global_attribute5 := p1_a28;
    ddp_cust_account_rec.global_attribute6 := p1_a29;
    ddp_cust_account_rec.global_attribute7 := p1_a30;
    ddp_cust_account_rec.global_attribute8 := p1_a31;
    ddp_cust_account_rec.global_attribute9 := p1_a32;
    ddp_cust_account_rec.global_attribute10 := p1_a33;
    ddp_cust_account_rec.global_attribute11 := p1_a34;
    ddp_cust_account_rec.global_attribute12 := p1_a35;
    ddp_cust_account_rec.global_attribute13 := p1_a36;
    ddp_cust_account_rec.global_attribute14 := p1_a37;
    ddp_cust_account_rec.global_attribute15 := p1_a38;
    ddp_cust_account_rec.global_attribute16 := p1_a39;
    ddp_cust_account_rec.global_attribute17 := p1_a40;
    ddp_cust_account_rec.global_attribute18 := p1_a41;
    ddp_cust_account_rec.global_attribute19 := p1_a42;
    ddp_cust_account_rec.global_attribute20 := p1_a43;
    ddp_cust_account_rec.orig_system_reference := p1_a44;
    ddp_cust_account_rec.orig_system := p1_a45;
    ddp_cust_account_rec.status := p1_a46;
    ddp_cust_account_rec.customer_type := p1_a47;
    ddp_cust_account_rec.customer_class_code := p1_a48;
    ddp_cust_account_rec.primary_salesrep_id := rosetta_g_miss_num_map(p1_a49);
    ddp_cust_account_rec.sales_channel_code := p1_a50;
    ddp_cust_account_rec.order_type_id := rosetta_g_miss_num_map(p1_a51);
    ddp_cust_account_rec.price_list_id := rosetta_g_miss_num_map(p1_a52);
    ddp_cust_account_rec.tax_code := p1_a53;
    ddp_cust_account_rec.fob_point := p1_a54;
    ddp_cust_account_rec.freight_term := p1_a55;
    ddp_cust_account_rec.ship_partial := p1_a56;
    ddp_cust_account_rec.ship_via := p1_a57;
    ddp_cust_account_rec.warehouse_id := rosetta_g_miss_num_map(p1_a58);
    ddp_cust_account_rec.tax_header_level_flag := p1_a59;
    ddp_cust_account_rec.tax_rounding_rule := p1_a60;
    ddp_cust_account_rec.coterminate_day_month := p1_a61;
    ddp_cust_account_rec.primary_specialist_id := rosetta_g_miss_num_map(p1_a62);
    ddp_cust_account_rec.secondary_specialist_id := rosetta_g_miss_num_map(p1_a63);
    ddp_cust_account_rec.account_liable_flag := p1_a64;
    ddp_cust_account_rec.current_balance := rosetta_g_miss_num_map(p1_a65);
    ddp_cust_account_rec.account_established_date := rosetta_g_miss_date_in_map(p1_a66);
    ddp_cust_account_rec.account_termination_date := rosetta_g_miss_date_in_map(p1_a67);
    ddp_cust_account_rec.account_activation_date := rosetta_g_miss_date_in_map(p1_a68);
    ddp_cust_account_rec.department := p1_a69;
    ddp_cust_account_rec.held_bill_expiration_date := rosetta_g_miss_date_in_map(p1_a70);
    ddp_cust_account_rec.hold_bill_flag := p1_a71;
    ddp_cust_account_rec.realtime_rate_flag := p1_a72;
    ddp_cust_account_rec.acct_life_cycle_status := p1_a73;
    ddp_cust_account_rec.account_name := p1_a74;
    ddp_cust_account_rec.deposit_refund_method := p1_a75;
    ddp_cust_account_rec.dormant_account_flag := p1_a76;
    ddp_cust_account_rec.npa_number := p1_a77;
    ddp_cust_account_rec.suspension_date := rosetta_g_miss_date_in_map(p1_a78);
    ddp_cust_account_rec.source_code := p1_a79;
    ddp_cust_account_rec.comments := p1_a80;
    ddp_cust_account_rec.dates_negative_tolerance := rosetta_g_miss_num_map(p1_a81);
    ddp_cust_account_rec.dates_positive_tolerance := rosetta_g_miss_num_map(p1_a82);
    ddp_cust_account_rec.date_type_preference := p1_a83;
    ddp_cust_account_rec.over_shipment_tolerance := rosetta_g_miss_num_map(p1_a84);
    ddp_cust_account_rec.under_shipment_tolerance := rosetta_g_miss_num_map(p1_a85);
    ddp_cust_account_rec.over_return_tolerance := rosetta_g_miss_num_map(p1_a86);
    ddp_cust_account_rec.under_return_tolerance := rosetta_g_miss_num_map(p1_a87);
    ddp_cust_account_rec.item_cross_ref_pref := p1_a88;
    ddp_cust_account_rec.ship_sets_include_lines_flag := p1_a89;
    ddp_cust_account_rec.arrivalsets_include_lines_flag := p1_a90;
    ddp_cust_account_rec.sched_date_push_flag := p1_a91;
    ddp_cust_account_rec.invoice_quantity_rule := p1_a92;
    ddp_cust_account_rec.pricing_event := p1_a93;
    ddp_cust_account_rec.status_update_date := rosetta_g_miss_date_in_map(p1_a94);
    ddp_cust_account_rec.autopay_flag := p1_a95;
    ddp_cust_account_rec.notify_flag := p1_a96;
    ddp_cust_account_rec.last_batch_id := rosetta_g_miss_num_map(p1_a97);
    ddp_cust_account_rec.selling_party_id := rosetta_g_miss_num_map(p1_a98);
    ddp_cust_account_rec.created_by_module := p1_a99;
    ddp_cust_account_rec.application_id := rosetta_g_miss_num_map(p1_a100);

    ddp_organization_rec.organization_name := p2_a0;
    ddp_organization_rec.duns_number_c := p2_a1;
    ddp_organization_rec.enquiry_duns := p2_a2;
    ddp_organization_rec.ceo_name := p2_a3;
    ddp_organization_rec.ceo_title := p2_a4;
    ddp_organization_rec.principal_name := p2_a5;
    ddp_organization_rec.principal_title := p2_a6;
    ddp_organization_rec.legal_status := p2_a7;
    ddp_organization_rec.control_yr := rosetta_g_miss_num_map(p2_a8);
    ddp_organization_rec.employees_total := rosetta_g_miss_num_map(p2_a9);
    ddp_organization_rec.hq_branch_ind := p2_a10;
    ddp_organization_rec.branch_flag := p2_a11;
    ddp_organization_rec.oob_ind := p2_a12;
    ddp_organization_rec.line_of_business := p2_a13;
    ddp_organization_rec.cong_dist_code := p2_a14;
    ddp_organization_rec.sic_code := p2_a15;
    ddp_organization_rec.import_ind := p2_a16;
    ddp_organization_rec.export_ind := p2_a17;
    ddp_organization_rec.labor_surplus_ind := p2_a18;
    ddp_organization_rec.debarment_ind := p2_a19;
    ddp_organization_rec.minority_owned_ind := p2_a20;
    ddp_organization_rec.minority_owned_type := p2_a21;
    ddp_organization_rec.woman_owned_ind := p2_a22;
    ddp_organization_rec.disadv_8a_ind := p2_a23;
    ddp_organization_rec.small_bus_ind := p2_a24;
    ddp_organization_rec.rent_own_ind := p2_a25;
    ddp_organization_rec.debarments_count := rosetta_g_miss_num_map(p2_a26);
    ddp_organization_rec.debarments_date := rosetta_g_miss_date_in_map(p2_a27);
    ddp_organization_rec.failure_score := p2_a28;
    ddp_organization_rec.failure_score_natnl_percentile := rosetta_g_miss_num_map(p2_a29);
    ddp_organization_rec.failure_score_override_code := p2_a30;
    ddp_organization_rec.failure_score_commentary := p2_a31;
    ddp_organization_rec.global_failure_score := p2_a32;
    ddp_organization_rec.db_rating := p2_a33;
    ddp_organization_rec.credit_score := p2_a34;
    ddp_organization_rec.credit_score_commentary := p2_a35;
    ddp_organization_rec.paydex_score := p2_a36;
    ddp_organization_rec.paydex_three_months_ago := p2_a37;
    ddp_organization_rec.paydex_norm := p2_a38;
    ddp_organization_rec.best_time_contact_begin := rosetta_g_miss_date_in_map(p2_a39);
    ddp_organization_rec.best_time_contact_end := rosetta_g_miss_date_in_map(p2_a40);
    ddp_organization_rec.organization_name_phonetic := p2_a41;
    ddp_organization_rec.tax_reference := p2_a42;
    ddp_organization_rec.gsa_indicator_flag := p2_a43;
    ddp_organization_rec.jgzz_fiscal_code := p2_a44;
    ddp_organization_rec.analysis_fy := p2_a45;
    ddp_organization_rec.fiscal_yearend_month := p2_a46;
    ddp_organization_rec.curr_fy_potential_revenue := rosetta_g_miss_num_map(p2_a47);
    ddp_organization_rec.next_fy_potential_revenue := rosetta_g_miss_num_map(p2_a48);
    ddp_organization_rec.year_established := rosetta_g_miss_num_map(p2_a49);
    ddp_organization_rec.mission_statement := p2_a50;
    ddp_organization_rec.organization_type := p2_a51;
    ddp_organization_rec.business_scope := p2_a52;
    ddp_organization_rec.corporation_class := p2_a53;
    ddp_organization_rec.known_as := p2_a54;
    ddp_organization_rec.known_as2 := p2_a55;
    ddp_organization_rec.known_as3 := p2_a56;
    ddp_organization_rec.known_as4 := p2_a57;
    ddp_organization_rec.known_as5 := p2_a58;
    ddp_organization_rec.local_bus_iden_type := p2_a59;
    ddp_organization_rec.local_bus_identifier := p2_a60;
    ddp_organization_rec.pref_functional_currency := p2_a61;
    ddp_organization_rec.registration_type := p2_a62;
    ddp_organization_rec.total_employees_text := p2_a63;
    ddp_organization_rec.total_employees_ind := p2_a64;
    ddp_organization_rec.total_emp_est_ind := p2_a65;
    ddp_organization_rec.total_emp_min_ind := p2_a66;
    ddp_organization_rec.parent_sub_ind := p2_a67;
    ddp_organization_rec.incorp_year := rosetta_g_miss_num_map(p2_a68);
    ddp_organization_rec.sic_code_type := p2_a69;
    ddp_organization_rec.public_private_ownership_flag := p2_a70;
    ddp_organization_rec.internal_flag := p2_a71;
    ddp_organization_rec.local_activity_code_type := p2_a72;
    ddp_organization_rec.local_activity_code := p2_a73;
    ddp_organization_rec.emp_at_primary_adr := p2_a74;
    ddp_organization_rec.emp_at_primary_adr_text := p2_a75;
    ddp_organization_rec.emp_at_primary_adr_est_ind := p2_a76;
    ddp_organization_rec.emp_at_primary_adr_min_ind := p2_a77;
    ddp_organization_rec.high_credit := rosetta_g_miss_num_map(p2_a78);
    ddp_organization_rec.avg_high_credit := rosetta_g_miss_num_map(p2_a79);
    ddp_organization_rec.total_payments := rosetta_g_miss_num_map(p2_a80);
    ddp_organization_rec.credit_score_class := rosetta_g_miss_num_map(p2_a81);
    ddp_organization_rec.credit_score_natl_percentile := rosetta_g_miss_num_map(p2_a82);
    ddp_organization_rec.credit_score_incd_default := rosetta_g_miss_num_map(p2_a83);
    ddp_organization_rec.credit_score_age := rosetta_g_miss_num_map(p2_a84);
    ddp_organization_rec.credit_score_date := rosetta_g_miss_date_in_map(p2_a85);
    ddp_organization_rec.credit_score_commentary2 := p2_a86;
    ddp_organization_rec.credit_score_commentary3 := p2_a87;
    ddp_organization_rec.credit_score_commentary4 := p2_a88;
    ddp_organization_rec.credit_score_commentary5 := p2_a89;
    ddp_organization_rec.credit_score_commentary6 := p2_a90;
    ddp_organization_rec.credit_score_commentary7 := p2_a91;
    ddp_organization_rec.credit_score_commentary8 := p2_a92;
    ddp_organization_rec.credit_score_commentary9 := p2_a93;
    ddp_organization_rec.credit_score_commentary10 := p2_a94;
    ddp_organization_rec.failure_score_class := rosetta_g_miss_num_map(p2_a95);
    ddp_organization_rec.failure_score_incd_default := rosetta_g_miss_num_map(p2_a96);
    ddp_organization_rec.failure_score_age := rosetta_g_miss_num_map(p2_a97);
    ddp_organization_rec.failure_score_date := rosetta_g_miss_date_in_map(p2_a98);
    ddp_organization_rec.failure_score_commentary2 := p2_a99;
    ddp_organization_rec.failure_score_commentary3 := p2_a100;
    ddp_organization_rec.failure_score_commentary4 := p2_a101;
    ddp_organization_rec.failure_score_commentary5 := p2_a102;
    ddp_organization_rec.failure_score_commentary6 := p2_a103;
    ddp_organization_rec.failure_score_commentary7 := p2_a104;
    ddp_organization_rec.failure_score_commentary8 := p2_a105;
    ddp_organization_rec.failure_score_commentary9 := p2_a106;
    ddp_organization_rec.failure_score_commentary10 := p2_a107;
    ddp_organization_rec.maximum_credit_recommendation := rosetta_g_miss_num_map(p2_a108);
    ddp_organization_rec.maximum_credit_currency_code := p2_a109;
    ddp_organization_rec.displayed_duns_party_id := rosetta_g_miss_num_map(p2_a110);
    ddp_organization_rec.content_source_type := p2_a111;
    ddp_organization_rec.content_source_number := p2_a112;
    ddp_organization_rec.attribute_category := p2_a113;
    ddp_organization_rec.attribute1 := p2_a114;
    ddp_organization_rec.attribute2 := p2_a115;
    ddp_organization_rec.attribute3 := p2_a116;
    ddp_organization_rec.attribute4 := p2_a117;
    ddp_organization_rec.attribute5 := p2_a118;
    ddp_organization_rec.attribute6 := p2_a119;
    ddp_organization_rec.attribute7 := p2_a120;
    ddp_organization_rec.attribute8 := p2_a121;
    ddp_organization_rec.attribute9 := p2_a122;
    ddp_organization_rec.attribute10 := p2_a123;
    ddp_organization_rec.attribute11 := p2_a124;
    ddp_organization_rec.attribute12 := p2_a125;
    ddp_organization_rec.attribute13 := p2_a126;
    ddp_organization_rec.attribute14 := p2_a127;
    ddp_organization_rec.attribute15 := p2_a128;
    ddp_organization_rec.attribute16 := p2_a129;
    ddp_organization_rec.attribute17 := p2_a130;
    ddp_organization_rec.attribute18 := p2_a131;
    ddp_organization_rec.attribute19 := p2_a132;
    ddp_organization_rec.attribute20 := p2_a133;
    ddp_organization_rec.created_by_module := p2_a134;
    ddp_organization_rec.application_id := rosetta_g_miss_num_map(p2_a135);
    ddp_organization_rec.do_not_confuse_with := p2_a136;
    ddp_organization_rec.actual_content_source := p2_a137;
    ddp_organization_rec.home_country := p2_a138;
    ddp_organization_rec.party_rec.party_id := rosetta_g_miss_num_map(p2_a139);
    ddp_organization_rec.party_rec.party_number := p2_a140;
    ddp_organization_rec.party_rec.validated_flag := p2_a141;
    ddp_organization_rec.party_rec.orig_system_reference := p2_a142;
    ddp_organization_rec.party_rec.orig_system := p2_a143;
    ddp_organization_rec.party_rec.status := p2_a144;
    ddp_organization_rec.party_rec.category_code := p2_a145;
    ddp_organization_rec.party_rec.salutation := p2_a146;
    ddp_organization_rec.party_rec.attribute_category := p2_a147;
    ddp_organization_rec.party_rec.attribute1 := p2_a148;
    ddp_organization_rec.party_rec.attribute2 := p2_a149;
    ddp_organization_rec.party_rec.attribute3 := p2_a150;
    ddp_organization_rec.party_rec.attribute4 := p2_a151;
    ddp_organization_rec.party_rec.attribute5 := p2_a152;
    ddp_organization_rec.party_rec.attribute6 := p2_a153;
    ddp_organization_rec.party_rec.attribute7 := p2_a154;
    ddp_organization_rec.party_rec.attribute8 := p2_a155;
    ddp_organization_rec.party_rec.attribute9 := p2_a156;
    ddp_organization_rec.party_rec.attribute10 := p2_a157;
    ddp_organization_rec.party_rec.attribute11 := p2_a158;
    ddp_organization_rec.party_rec.attribute12 := p2_a159;
    ddp_organization_rec.party_rec.attribute13 := p2_a160;
    ddp_organization_rec.party_rec.attribute14 := p2_a161;
    ddp_organization_rec.party_rec.attribute15 := p2_a162;
    ddp_organization_rec.party_rec.attribute16 := p2_a163;
    ddp_organization_rec.party_rec.attribute17 := p2_a164;
    ddp_organization_rec.party_rec.attribute18 := p2_a165;
    ddp_organization_rec.party_rec.attribute19 := p2_a166;
    ddp_organization_rec.party_rec.attribute20 := p2_a167;
    ddp_organization_rec.party_rec.attribute21 := p2_a168;
    ddp_organization_rec.party_rec.attribute22 := p2_a169;
    ddp_organization_rec.party_rec.attribute23 := p2_a170;
    ddp_organization_rec.party_rec.attribute24 := p2_a171;

    ddp_customer_profile_rec.cust_account_profile_id := rosetta_g_miss_num_map(p3_a0);
    ddp_customer_profile_rec.cust_account_id := rosetta_g_miss_num_map(p3_a1);
    ddp_customer_profile_rec.status := p3_a2;
    ddp_customer_profile_rec.collector_id := rosetta_g_miss_num_map(p3_a3);
    ddp_customer_profile_rec.credit_analyst_id := rosetta_g_miss_num_map(p3_a4);
    ddp_customer_profile_rec.credit_checking := p3_a5;
    ddp_customer_profile_rec.next_credit_review_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_customer_profile_rec.tolerance := rosetta_g_miss_num_map(p3_a7);
    ddp_customer_profile_rec.discount_terms := p3_a8;
    ddp_customer_profile_rec.dunning_letters := p3_a9;
    ddp_customer_profile_rec.interest_charges := p3_a10;
    ddp_customer_profile_rec.send_statements := p3_a11;
    ddp_customer_profile_rec.credit_balance_statements := p3_a12;
    ddp_customer_profile_rec.credit_hold := p3_a13;
    ddp_customer_profile_rec.profile_class_id := rosetta_g_miss_num_map(p3_a14);
    ddp_customer_profile_rec.site_use_id := rosetta_g_miss_num_map(p3_a15);
    ddp_customer_profile_rec.credit_rating := p3_a16;
    ddp_customer_profile_rec.risk_code := p3_a17;
    ddp_customer_profile_rec.standard_terms := rosetta_g_miss_num_map(p3_a18);
    ddp_customer_profile_rec.override_terms := p3_a19;
    ddp_customer_profile_rec.dunning_letter_set_id := rosetta_g_miss_num_map(p3_a20);
    ddp_customer_profile_rec.interest_period_days := rosetta_g_miss_num_map(p3_a21);
    ddp_customer_profile_rec.payment_grace_days := rosetta_g_miss_num_map(p3_a22);
    ddp_customer_profile_rec.discount_grace_days := rosetta_g_miss_num_map(p3_a23);
    ddp_customer_profile_rec.statement_cycle_id := rosetta_g_miss_num_map(p3_a24);
    ddp_customer_profile_rec.account_status := p3_a25;
    ddp_customer_profile_rec.percent_collectable := rosetta_g_miss_num_map(p3_a26);
    ddp_customer_profile_rec.autocash_hierarchy_id := rosetta_g_miss_num_map(p3_a27);
    ddp_customer_profile_rec.attribute_category := p3_a28;
    ddp_customer_profile_rec.attribute1 := p3_a29;
    ddp_customer_profile_rec.attribute2 := p3_a30;
    ddp_customer_profile_rec.attribute3 := p3_a31;
    ddp_customer_profile_rec.attribute4 := p3_a32;
    ddp_customer_profile_rec.attribute5 := p3_a33;
    ddp_customer_profile_rec.attribute6 := p3_a34;
    ddp_customer_profile_rec.attribute7 := p3_a35;
    ddp_customer_profile_rec.attribute8 := p3_a36;
    ddp_customer_profile_rec.attribute9 := p3_a37;
    ddp_customer_profile_rec.attribute10 := p3_a38;
    ddp_customer_profile_rec.attribute11 := p3_a39;
    ddp_customer_profile_rec.attribute12 := p3_a40;
    ddp_customer_profile_rec.attribute13 := p3_a41;
    ddp_customer_profile_rec.attribute14 := p3_a42;
    ddp_customer_profile_rec.attribute15 := p3_a43;
    ddp_customer_profile_rec.auto_rec_incl_disputed_flag := p3_a44;
    ddp_customer_profile_rec.tax_printing_option := p3_a45;
    ddp_customer_profile_rec.charge_on_finance_charge_flag := p3_a46;
    ddp_customer_profile_rec.grouping_rule_id := rosetta_g_miss_num_map(p3_a47);
    ddp_customer_profile_rec.clearing_days := rosetta_g_miss_num_map(p3_a48);
    ddp_customer_profile_rec.jgzz_attribute_category := p3_a49;
    ddp_customer_profile_rec.jgzz_attribute1 := p3_a50;
    ddp_customer_profile_rec.jgzz_attribute2 := p3_a51;
    ddp_customer_profile_rec.jgzz_attribute3 := p3_a52;
    ddp_customer_profile_rec.jgzz_attribute4 := p3_a53;
    ddp_customer_profile_rec.jgzz_attribute5 := p3_a54;
    ddp_customer_profile_rec.jgzz_attribute6 := p3_a55;
    ddp_customer_profile_rec.jgzz_attribute7 := p3_a56;
    ddp_customer_profile_rec.jgzz_attribute8 := p3_a57;
    ddp_customer_profile_rec.jgzz_attribute9 := p3_a58;
    ddp_customer_profile_rec.jgzz_attribute10 := p3_a59;
    ddp_customer_profile_rec.jgzz_attribute11 := p3_a60;
    ddp_customer_profile_rec.jgzz_attribute12 := p3_a61;
    ddp_customer_profile_rec.jgzz_attribute13 := p3_a62;
    ddp_customer_profile_rec.jgzz_attribute14 := p3_a63;
    ddp_customer_profile_rec.jgzz_attribute15 := p3_a64;
    ddp_customer_profile_rec.global_attribute1 := p3_a65;
    ddp_customer_profile_rec.global_attribute2 := p3_a66;
    ddp_customer_profile_rec.global_attribute3 := p3_a67;
    ddp_customer_profile_rec.global_attribute4 := p3_a68;
    ddp_customer_profile_rec.global_attribute5 := p3_a69;
    ddp_customer_profile_rec.global_attribute6 := p3_a70;
    ddp_customer_profile_rec.global_attribute7 := p3_a71;
    ddp_customer_profile_rec.global_attribute8 := p3_a72;
    ddp_customer_profile_rec.global_attribute9 := p3_a73;
    ddp_customer_profile_rec.global_attribute10 := p3_a74;
    ddp_customer_profile_rec.global_attribute11 := p3_a75;
    ddp_customer_profile_rec.global_attribute12 := p3_a76;
    ddp_customer_profile_rec.global_attribute13 := p3_a77;
    ddp_customer_profile_rec.global_attribute14 := p3_a78;
    ddp_customer_profile_rec.global_attribute15 := p3_a79;
    ddp_customer_profile_rec.global_attribute16 := p3_a80;
    ddp_customer_profile_rec.global_attribute17 := p3_a81;
    ddp_customer_profile_rec.global_attribute18 := p3_a82;
    ddp_customer_profile_rec.global_attribute19 := p3_a83;
    ddp_customer_profile_rec.global_attribute20 := p3_a84;
    ddp_customer_profile_rec.global_attribute_category := p3_a85;
    ddp_customer_profile_rec.cons_inv_flag := p3_a86;
    ddp_customer_profile_rec.cons_inv_type := p3_a87;
    ddp_customer_profile_rec.autocash_hierarchy_id_for_adr := rosetta_g_miss_num_map(p3_a88);
    ddp_customer_profile_rec.lockbox_matching_option := p3_a89;
    ddp_customer_profile_rec.created_by_module := p3_a90;
    ddp_customer_profile_rec.application_id := rosetta_g_miss_num_map(p3_a91);
    ddp_customer_profile_rec.review_cycle := p3_a92;
    ddp_customer_profile_rec.last_credit_review_date := rosetta_g_miss_date_in_map(p3_a93);
    ddp_customer_profile_rec.party_id := rosetta_g_miss_num_map(p3_a94);
    ddp_customer_profile_rec.credit_classification := p3_a95;
    ddp_customer_profile_rec.cons_bill_level := p3_a96;
    ddp_customer_profile_rec.late_charge_calculation_trx := p3_a97;
    ddp_customer_profile_rec.credit_items_flag := p3_a98;
    ddp_customer_profile_rec.disputed_transactions_flag := p3_a99;
    ddp_customer_profile_rec.late_charge_type := p3_a100;
    ddp_customer_profile_rec.late_charge_term_id := rosetta_g_miss_num_map(p3_a101);
    ddp_customer_profile_rec.interest_calculation_period := p3_a102;
    ddp_customer_profile_rec.hold_charged_invoices_flag := p3_a103;
    ddp_customer_profile_rec.message_text_id := rosetta_g_miss_num_map(p3_a104);
    ddp_customer_profile_rec.multiple_interest_rates_flag := p3_a105;
    ddp_customer_profile_rec.charge_begin_date := rosetta_g_miss_date_in_map(p3_a106);










    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.create_cust_account(p_init_msg_list,
      ddp_cust_account_rec,
      ddp_organization_rec,
      ddp_customer_profile_rec,
      p_create_profile_amt,
      x_cust_account_id,
      x_account_number,
      x_party_id,
      x_party_number,
      x_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any












  end;

  procedure update_cust_account_3(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  VARCHAR2 := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  VARCHAR2 := null
    , p1_a27  VARCHAR2 := null
    , p1_a28  VARCHAR2 := null
    , p1_a29  VARCHAR2 := null
    , p1_a30  VARCHAR2 := null
    , p1_a31  VARCHAR2 := null
    , p1_a32  VARCHAR2 := null
    , p1_a33  VARCHAR2 := null
    , p1_a34  VARCHAR2 := null
    , p1_a35  VARCHAR2 := null
    , p1_a36  VARCHAR2 := null
    , p1_a37  VARCHAR2 := null
    , p1_a38  VARCHAR2 := null
    , p1_a39  VARCHAR2 := null
    , p1_a40  VARCHAR2 := null
    , p1_a41  VARCHAR2 := null
    , p1_a42  VARCHAR2 := null
    , p1_a43  VARCHAR2 := null
    , p1_a44  VARCHAR2 := null
    , p1_a45  VARCHAR2 := null
    , p1_a46  VARCHAR2 := null
    , p1_a47  VARCHAR2 := null
    , p1_a48  VARCHAR2 := null
    , p1_a49  NUMBER := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  NUMBER := null
    , p1_a52  NUMBER := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  NUMBER := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  NUMBER := null
    , p1_a63  NUMBER := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  NUMBER := null
    , p1_a66  DATE := null
    , p1_a67  DATE := null
    , p1_a68  DATE := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  DATE := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  DATE := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  NUMBER := null
    , p1_a85  NUMBER := null
    , p1_a86  NUMBER := null
    , p1_a87  NUMBER := null
    , p1_a88  VARCHAR2 := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  VARCHAR2 := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  VARCHAR2 := null
    , p1_a94  DATE := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  NUMBER := null
    , p1_a98  NUMBER := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  NUMBER := null
  )
  as
    ddp_cust_account_rec hz_cust_account_v2pub.cust_account_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_account_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_account_rec.account_number := p1_a1;
    ddp_cust_account_rec.attribute_category := p1_a2;
    ddp_cust_account_rec.attribute1 := p1_a3;
    ddp_cust_account_rec.attribute2 := p1_a4;
    ddp_cust_account_rec.attribute3 := p1_a5;
    ddp_cust_account_rec.attribute4 := p1_a6;
    ddp_cust_account_rec.attribute5 := p1_a7;
    ddp_cust_account_rec.attribute6 := p1_a8;
    ddp_cust_account_rec.attribute7 := p1_a9;
    ddp_cust_account_rec.attribute8 := p1_a10;
    ddp_cust_account_rec.attribute9 := p1_a11;
    ddp_cust_account_rec.attribute10 := p1_a12;
    ddp_cust_account_rec.attribute11 := p1_a13;
    ddp_cust_account_rec.attribute12 := p1_a14;
    ddp_cust_account_rec.attribute13 := p1_a15;
    ddp_cust_account_rec.attribute14 := p1_a16;
    ddp_cust_account_rec.attribute15 := p1_a17;
    ddp_cust_account_rec.attribute16 := p1_a18;
    ddp_cust_account_rec.attribute17 := p1_a19;
    ddp_cust_account_rec.attribute18 := p1_a20;
    ddp_cust_account_rec.attribute19 := p1_a21;
    ddp_cust_account_rec.attribute20 := p1_a22;
    ddp_cust_account_rec.global_attribute_category := p1_a23;
    ddp_cust_account_rec.global_attribute1 := p1_a24;
    ddp_cust_account_rec.global_attribute2 := p1_a25;
    ddp_cust_account_rec.global_attribute3 := p1_a26;
    ddp_cust_account_rec.global_attribute4 := p1_a27;
    ddp_cust_account_rec.global_attribute5 := p1_a28;
    ddp_cust_account_rec.global_attribute6 := p1_a29;
    ddp_cust_account_rec.global_attribute7 := p1_a30;
    ddp_cust_account_rec.global_attribute8 := p1_a31;
    ddp_cust_account_rec.global_attribute9 := p1_a32;
    ddp_cust_account_rec.global_attribute10 := p1_a33;
    ddp_cust_account_rec.global_attribute11 := p1_a34;
    ddp_cust_account_rec.global_attribute12 := p1_a35;
    ddp_cust_account_rec.global_attribute13 := p1_a36;
    ddp_cust_account_rec.global_attribute14 := p1_a37;
    ddp_cust_account_rec.global_attribute15 := p1_a38;
    ddp_cust_account_rec.global_attribute16 := p1_a39;
    ddp_cust_account_rec.global_attribute17 := p1_a40;
    ddp_cust_account_rec.global_attribute18 := p1_a41;
    ddp_cust_account_rec.global_attribute19 := p1_a42;
    ddp_cust_account_rec.global_attribute20 := p1_a43;
    ddp_cust_account_rec.orig_system_reference := p1_a44;
    ddp_cust_account_rec.orig_system := p1_a45;
    ddp_cust_account_rec.status := p1_a46;
    ddp_cust_account_rec.customer_type := p1_a47;
    ddp_cust_account_rec.customer_class_code := p1_a48;
    ddp_cust_account_rec.primary_salesrep_id := rosetta_g_miss_num_map(p1_a49);
    ddp_cust_account_rec.sales_channel_code := p1_a50;
    ddp_cust_account_rec.order_type_id := rosetta_g_miss_num_map(p1_a51);
    ddp_cust_account_rec.price_list_id := rosetta_g_miss_num_map(p1_a52);
    ddp_cust_account_rec.tax_code := p1_a53;
    ddp_cust_account_rec.fob_point := p1_a54;
    ddp_cust_account_rec.freight_term := p1_a55;
    ddp_cust_account_rec.ship_partial := p1_a56;
    ddp_cust_account_rec.ship_via := p1_a57;
    ddp_cust_account_rec.warehouse_id := rosetta_g_miss_num_map(p1_a58);
    ddp_cust_account_rec.tax_header_level_flag := p1_a59;
    ddp_cust_account_rec.tax_rounding_rule := p1_a60;
    ddp_cust_account_rec.coterminate_day_month := p1_a61;
    ddp_cust_account_rec.primary_specialist_id := rosetta_g_miss_num_map(p1_a62);
    ddp_cust_account_rec.secondary_specialist_id := rosetta_g_miss_num_map(p1_a63);
    ddp_cust_account_rec.account_liable_flag := p1_a64;
    ddp_cust_account_rec.current_balance := rosetta_g_miss_num_map(p1_a65);
    ddp_cust_account_rec.account_established_date := rosetta_g_miss_date_in_map(p1_a66);
    ddp_cust_account_rec.account_termination_date := rosetta_g_miss_date_in_map(p1_a67);
    ddp_cust_account_rec.account_activation_date := rosetta_g_miss_date_in_map(p1_a68);
    ddp_cust_account_rec.department := p1_a69;
    ddp_cust_account_rec.held_bill_expiration_date := rosetta_g_miss_date_in_map(p1_a70);
    ddp_cust_account_rec.hold_bill_flag := p1_a71;
    ddp_cust_account_rec.realtime_rate_flag := p1_a72;
    ddp_cust_account_rec.acct_life_cycle_status := p1_a73;
    ddp_cust_account_rec.account_name := p1_a74;
    ddp_cust_account_rec.deposit_refund_method := p1_a75;
    ddp_cust_account_rec.dormant_account_flag := p1_a76;
    ddp_cust_account_rec.npa_number := p1_a77;
    ddp_cust_account_rec.suspension_date := rosetta_g_miss_date_in_map(p1_a78);
    ddp_cust_account_rec.source_code := p1_a79;
    ddp_cust_account_rec.comments := p1_a80;
    ddp_cust_account_rec.dates_negative_tolerance := rosetta_g_miss_num_map(p1_a81);
    ddp_cust_account_rec.dates_positive_tolerance := rosetta_g_miss_num_map(p1_a82);
    ddp_cust_account_rec.date_type_preference := p1_a83;
    ddp_cust_account_rec.over_shipment_tolerance := rosetta_g_miss_num_map(p1_a84);
    ddp_cust_account_rec.under_shipment_tolerance := rosetta_g_miss_num_map(p1_a85);
    ddp_cust_account_rec.over_return_tolerance := rosetta_g_miss_num_map(p1_a86);
    ddp_cust_account_rec.under_return_tolerance := rosetta_g_miss_num_map(p1_a87);
    ddp_cust_account_rec.item_cross_ref_pref := p1_a88;
    ddp_cust_account_rec.ship_sets_include_lines_flag := p1_a89;
    ddp_cust_account_rec.arrivalsets_include_lines_flag := p1_a90;
    ddp_cust_account_rec.sched_date_push_flag := p1_a91;
    ddp_cust_account_rec.invoice_quantity_rule := p1_a92;
    ddp_cust_account_rec.pricing_event := p1_a93;
    ddp_cust_account_rec.status_update_date := rosetta_g_miss_date_in_map(p1_a94);
    ddp_cust_account_rec.autopay_flag := p1_a95;
    ddp_cust_account_rec.notify_flag := p1_a96;
    ddp_cust_account_rec.last_batch_id := rosetta_g_miss_num_map(p1_a97);
    ddp_cust_account_rec.selling_party_id := rosetta_g_miss_num_map(p1_a98);
    ddp_cust_account_rec.created_by_module := p1_a99;
    ddp_cust_account_rec.application_id := rosetta_g_miss_num_map(p1_a100);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.update_cust_account(p_init_msg_list,
      ddp_cust_account_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_cust_account_rec_4(p_init_msg_list  VARCHAR2
    , p_cust_account_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  VARCHAR2
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  VARCHAR2
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  VARCHAR2
    , p2_a27 out nocopy  VARCHAR2
    , p2_a28 out nocopy  VARCHAR2
    , p2_a29 out nocopy  VARCHAR2
    , p2_a30 out nocopy  VARCHAR2
    , p2_a31 out nocopy  VARCHAR2
    , p2_a32 out nocopy  VARCHAR2
    , p2_a33 out nocopy  VARCHAR2
    , p2_a34 out nocopy  VARCHAR2
    , p2_a35 out nocopy  VARCHAR2
    , p2_a36 out nocopy  VARCHAR2
    , p2_a37 out nocopy  VARCHAR2
    , p2_a38 out nocopy  VARCHAR2
    , p2_a39 out nocopy  VARCHAR2
    , p2_a40 out nocopy  VARCHAR2
    , p2_a41 out nocopy  VARCHAR2
    , p2_a42 out nocopy  VARCHAR2
    , p2_a43 out nocopy  VARCHAR2
    , p2_a44 out nocopy  VARCHAR2
    , p2_a45 out nocopy  VARCHAR2
    , p2_a46 out nocopy  VARCHAR2
    , p2_a47 out nocopy  VARCHAR2
    , p2_a48 out nocopy  VARCHAR2
    , p2_a49 out nocopy  NUMBER
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  NUMBER
    , p2_a52 out nocopy  NUMBER
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  NUMBER
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  NUMBER
    , p2_a63 out nocopy  NUMBER
    , p2_a64 out nocopy  VARCHAR2
    , p2_a65 out nocopy  NUMBER
    , p2_a66 out nocopy  DATE
    , p2_a67 out nocopy  DATE
    , p2_a68 out nocopy  DATE
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  DATE
    , p2_a71 out nocopy  VARCHAR2
    , p2_a72 out nocopy  VARCHAR2
    , p2_a73 out nocopy  VARCHAR2
    , p2_a74 out nocopy  VARCHAR2
    , p2_a75 out nocopy  VARCHAR2
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  VARCHAR2
    , p2_a78 out nocopy  DATE
    , p2_a79 out nocopy  VARCHAR2
    , p2_a80 out nocopy  VARCHAR2
    , p2_a81 out nocopy  NUMBER
    , p2_a82 out nocopy  NUMBER
    , p2_a83 out nocopy  VARCHAR2
    , p2_a84 out nocopy  NUMBER
    , p2_a85 out nocopy  NUMBER
    , p2_a86 out nocopy  NUMBER
    , p2_a87 out nocopy  NUMBER
    , p2_a88 out nocopy  VARCHAR2
    , p2_a89 out nocopy  VARCHAR2
    , p2_a90 out nocopy  VARCHAR2
    , p2_a91 out nocopy  VARCHAR2
    , p2_a92 out nocopy  VARCHAR2
    , p2_a93 out nocopy  VARCHAR2
    , p2_a94 out nocopy  DATE
    , p2_a95 out nocopy  VARCHAR2
    , p2_a96 out nocopy  VARCHAR2
    , p2_a97 out nocopy  NUMBER
    , p2_a98 out nocopy  NUMBER
    , p2_a99 out nocopy  VARCHAR2
    , p2_a100 out nocopy  NUMBER
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  DATE
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  VARCHAR2
    , p3_a9 out nocopy  VARCHAR2
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  NUMBER
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  VARCHAR2
    , p3_a18 out nocopy  NUMBER
    , p3_a19 out nocopy  VARCHAR2
    , p3_a20 out nocopy  NUMBER
    , p3_a21 out nocopy  NUMBER
    , p3_a22 out nocopy  NUMBER
    , p3_a23 out nocopy  NUMBER
    , p3_a24 out nocopy  NUMBER
    , p3_a25 out nocopy  VARCHAR2
    , p3_a26 out nocopy  NUMBER
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  VARCHAR2
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  VARCHAR2
    , p3_a37 out nocopy  VARCHAR2
    , p3_a38 out nocopy  VARCHAR2
    , p3_a39 out nocopy  VARCHAR2
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  VARCHAR2
    , p3_a43 out nocopy  VARCHAR2
    , p3_a44 out nocopy  VARCHAR2
    , p3_a45 out nocopy  VARCHAR2
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  NUMBER
    , p3_a48 out nocopy  NUMBER
    , p3_a49 out nocopy  VARCHAR2
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  VARCHAR2
    , p3_a52 out nocopy  VARCHAR2
    , p3_a53 out nocopy  VARCHAR2
    , p3_a54 out nocopy  VARCHAR2
    , p3_a55 out nocopy  VARCHAR2
    , p3_a56 out nocopy  VARCHAR2
    , p3_a57 out nocopy  VARCHAR2
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  VARCHAR2
    , p3_a60 out nocopy  VARCHAR2
    , p3_a61 out nocopy  VARCHAR2
    , p3_a62 out nocopy  VARCHAR2
    , p3_a63 out nocopy  VARCHAR2
    , p3_a64 out nocopy  VARCHAR2
    , p3_a65 out nocopy  VARCHAR2
    , p3_a66 out nocopy  VARCHAR2
    , p3_a67 out nocopy  VARCHAR2
    , p3_a68 out nocopy  VARCHAR2
    , p3_a69 out nocopy  VARCHAR2
    , p3_a70 out nocopy  VARCHAR2
    , p3_a71 out nocopy  VARCHAR2
    , p3_a72 out nocopy  VARCHAR2
    , p3_a73 out nocopy  VARCHAR2
    , p3_a74 out nocopy  VARCHAR2
    , p3_a75 out nocopy  VARCHAR2
    , p3_a76 out nocopy  VARCHAR2
    , p3_a77 out nocopy  VARCHAR2
    , p3_a78 out nocopy  VARCHAR2
    , p3_a79 out nocopy  VARCHAR2
    , p3_a80 out nocopy  VARCHAR2
    , p3_a81 out nocopy  VARCHAR2
    , p3_a82 out nocopy  VARCHAR2
    , p3_a83 out nocopy  VARCHAR2
    , p3_a84 out nocopy  VARCHAR2
    , p3_a85 out nocopy  VARCHAR2
    , p3_a86 out nocopy  VARCHAR2
    , p3_a87 out nocopy  VARCHAR2
    , p3_a88 out nocopy  NUMBER
    , p3_a89 out nocopy  VARCHAR2
    , p3_a90 out nocopy  VARCHAR2
    , p3_a91 out nocopy  NUMBER
    , p3_a92 out nocopy  VARCHAR2
    , p3_a93 out nocopy  DATE
    , p3_a94 out nocopy  NUMBER
    , p3_a95 out nocopy  VARCHAR2
    , p3_a96 out nocopy  VARCHAR2
    , p3_a97 out nocopy  VARCHAR2
    , p3_a98 out nocopy  VARCHAR2
    , p3_a99 out nocopy  VARCHAR2
    , p3_a100 out nocopy  VARCHAR2
    , p3_a101 out nocopy  NUMBER
    , p3_a102 out nocopy  VARCHAR2
    , p3_a103 out nocopy  VARCHAR2
    , p3_a104 out nocopy  NUMBER
    , p3_a105 out nocopy  VARCHAR2
    , p3_a106 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_cust_account_rec hz_cust_account_v2pub.cust_account_rec_type;
    ddx_customer_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.get_cust_account_rec(p_init_msg_list,
      p_cust_account_id,
      ddx_cust_account_rec,
      ddx_customer_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_cust_account_rec.cust_account_id);
    p2_a1 := ddx_cust_account_rec.account_number;
    p2_a2 := ddx_cust_account_rec.attribute_category;
    p2_a3 := ddx_cust_account_rec.attribute1;
    p2_a4 := ddx_cust_account_rec.attribute2;
    p2_a5 := ddx_cust_account_rec.attribute3;
    p2_a6 := ddx_cust_account_rec.attribute4;
    p2_a7 := ddx_cust_account_rec.attribute5;
    p2_a8 := ddx_cust_account_rec.attribute6;
    p2_a9 := ddx_cust_account_rec.attribute7;
    p2_a10 := ddx_cust_account_rec.attribute8;
    p2_a11 := ddx_cust_account_rec.attribute9;
    p2_a12 := ddx_cust_account_rec.attribute10;
    p2_a13 := ddx_cust_account_rec.attribute11;
    p2_a14 := ddx_cust_account_rec.attribute12;
    p2_a15 := ddx_cust_account_rec.attribute13;
    p2_a16 := ddx_cust_account_rec.attribute14;
    p2_a17 := ddx_cust_account_rec.attribute15;
    p2_a18 := ddx_cust_account_rec.attribute16;
    p2_a19 := ddx_cust_account_rec.attribute17;
    p2_a20 := ddx_cust_account_rec.attribute18;
    p2_a21 := ddx_cust_account_rec.attribute19;
    p2_a22 := ddx_cust_account_rec.attribute20;
    p2_a23 := ddx_cust_account_rec.global_attribute_category;
    p2_a24 := ddx_cust_account_rec.global_attribute1;
    p2_a25 := ddx_cust_account_rec.global_attribute2;
    p2_a26 := ddx_cust_account_rec.global_attribute3;
    p2_a27 := ddx_cust_account_rec.global_attribute4;
    p2_a28 := ddx_cust_account_rec.global_attribute5;
    p2_a29 := ddx_cust_account_rec.global_attribute6;
    p2_a30 := ddx_cust_account_rec.global_attribute7;
    p2_a31 := ddx_cust_account_rec.global_attribute8;
    p2_a32 := ddx_cust_account_rec.global_attribute9;
    p2_a33 := ddx_cust_account_rec.global_attribute10;
    p2_a34 := ddx_cust_account_rec.global_attribute11;
    p2_a35 := ddx_cust_account_rec.global_attribute12;
    p2_a36 := ddx_cust_account_rec.global_attribute13;
    p2_a37 := ddx_cust_account_rec.global_attribute14;
    p2_a38 := ddx_cust_account_rec.global_attribute15;
    p2_a39 := ddx_cust_account_rec.global_attribute16;
    p2_a40 := ddx_cust_account_rec.global_attribute17;
    p2_a41 := ddx_cust_account_rec.global_attribute18;
    p2_a42 := ddx_cust_account_rec.global_attribute19;
    p2_a43 := ddx_cust_account_rec.global_attribute20;
    p2_a44 := ddx_cust_account_rec.orig_system_reference;
    p2_a45 := ddx_cust_account_rec.orig_system;
    p2_a46 := ddx_cust_account_rec.status;
    p2_a47 := ddx_cust_account_rec.customer_type;
    p2_a48 := ddx_cust_account_rec.customer_class_code;
    p2_a49 := rosetta_g_miss_num_map(ddx_cust_account_rec.primary_salesrep_id);
    p2_a50 := ddx_cust_account_rec.sales_channel_code;
    p2_a51 := rosetta_g_miss_num_map(ddx_cust_account_rec.order_type_id);
    p2_a52 := rosetta_g_miss_num_map(ddx_cust_account_rec.price_list_id);
    p2_a53 := ddx_cust_account_rec.tax_code;
    p2_a54 := ddx_cust_account_rec.fob_point;
    p2_a55 := ddx_cust_account_rec.freight_term;
    p2_a56 := ddx_cust_account_rec.ship_partial;
    p2_a57 := ddx_cust_account_rec.ship_via;
    p2_a58 := rosetta_g_miss_num_map(ddx_cust_account_rec.warehouse_id);
    p2_a59 := ddx_cust_account_rec.tax_header_level_flag;
    p2_a60 := ddx_cust_account_rec.tax_rounding_rule;
    p2_a61 := ddx_cust_account_rec.coterminate_day_month;
    p2_a62 := rosetta_g_miss_num_map(ddx_cust_account_rec.primary_specialist_id);
    p2_a63 := rosetta_g_miss_num_map(ddx_cust_account_rec.secondary_specialist_id);
    p2_a64 := ddx_cust_account_rec.account_liable_flag;
    p2_a65 := rosetta_g_miss_num_map(ddx_cust_account_rec.current_balance);
    p2_a66 := ddx_cust_account_rec.account_established_date;
    p2_a67 := ddx_cust_account_rec.account_termination_date;
    p2_a68 := ddx_cust_account_rec.account_activation_date;
    p2_a69 := ddx_cust_account_rec.department;
    p2_a70 := ddx_cust_account_rec.held_bill_expiration_date;
    p2_a71 := ddx_cust_account_rec.hold_bill_flag;
    p2_a72 := ddx_cust_account_rec.realtime_rate_flag;
    p2_a73 := ddx_cust_account_rec.acct_life_cycle_status;
    p2_a74 := ddx_cust_account_rec.account_name;
    p2_a75 := ddx_cust_account_rec.deposit_refund_method;
    p2_a76 := ddx_cust_account_rec.dormant_account_flag;
    p2_a77 := ddx_cust_account_rec.npa_number;
    p2_a78 := ddx_cust_account_rec.suspension_date;
    p2_a79 := ddx_cust_account_rec.source_code;
    p2_a80 := ddx_cust_account_rec.comments;
    p2_a81 := rosetta_g_miss_num_map(ddx_cust_account_rec.dates_negative_tolerance);
    p2_a82 := rosetta_g_miss_num_map(ddx_cust_account_rec.dates_positive_tolerance);
    p2_a83 := ddx_cust_account_rec.date_type_preference;
    p2_a84 := rosetta_g_miss_num_map(ddx_cust_account_rec.over_shipment_tolerance);
    p2_a85 := rosetta_g_miss_num_map(ddx_cust_account_rec.under_shipment_tolerance);
    p2_a86 := rosetta_g_miss_num_map(ddx_cust_account_rec.over_return_tolerance);
    p2_a87 := rosetta_g_miss_num_map(ddx_cust_account_rec.under_return_tolerance);
    p2_a88 := ddx_cust_account_rec.item_cross_ref_pref;
    p2_a89 := ddx_cust_account_rec.ship_sets_include_lines_flag;
    p2_a90 := ddx_cust_account_rec.arrivalsets_include_lines_flag;
    p2_a91 := ddx_cust_account_rec.sched_date_push_flag;
    p2_a92 := ddx_cust_account_rec.invoice_quantity_rule;
    p2_a93 := ddx_cust_account_rec.pricing_event;
    p2_a94 := ddx_cust_account_rec.status_update_date;
    p2_a95 := ddx_cust_account_rec.autopay_flag;
    p2_a96 := ddx_cust_account_rec.notify_flag;
    p2_a97 := rosetta_g_miss_num_map(ddx_cust_account_rec.last_batch_id);
    p2_a98 := rosetta_g_miss_num_map(ddx_cust_account_rec.selling_party_id);
    p2_a99 := ddx_cust_account_rec.created_by_module;
    p2_a100 := rosetta_g_miss_num_map(ddx_cust_account_rec.application_id);

    p3_a0 := rosetta_g_miss_num_map(ddx_customer_profile_rec.cust_account_profile_id);
    p3_a1 := rosetta_g_miss_num_map(ddx_customer_profile_rec.cust_account_id);
    p3_a2 := ddx_customer_profile_rec.status;
    p3_a3 := rosetta_g_miss_num_map(ddx_customer_profile_rec.collector_id);
    p3_a4 := rosetta_g_miss_num_map(ddx_customer_profile_rec.credit_analyst_id);
    p3_a5 := ddx_customer_profile_rec.credit_checking;
    p3_a6 := ddx_customer_profile_rec.next_credit_review_date;
    p3_a7 := rosetta_g_miss_num_map(ddx_customer_profile_rec.tolerance);
    p3_a8 := ddx_customer_profile_rec.discount_terms;
    p3_a9 := ddx_customer_profile_rec.dunning_letters;
    p3_a10 := ddx_customer_profile_rec.interest_charges;
    p3_a11 := ddx_customer_profile_rec.send_statements;
    p3_a12 := ddx_customer_profile_rec.credit_balance_statements;
    p3_a13 := ddx_customer_profile_rec.credit_hold;
    p3_a14 := rosetta_g_miss_num_map(ddx_customer_profile_rec.profile_class_id);
    p3_a15 := rosetta_g_miss_num_map(ddx_customer_profile_rec.site_use_id);
    p3_a16 := ddx_customer_profile_rec.credit_rating;
    p3_a17 := ddx_customer_profile_rec.risk_code;
    p3_a18 := rosetta_g_miss_num_map(ddx_customer_profile_rec.standard_terms);
    p3_a19 := ddx_customer_profile_rec.override_terms;
    p3_a20 := rosetta_g_miss_num_map(ddx_customer_profile_rec.dunning_letter_set_id);
    p3_a21 := rosetta_g_miss_num_map(ddx_customer_profile_rec.interest_period_days);
    p3_a22 := rosetta_g_miss_num_map(ddx_customer_profile_rec.payment_grace_days);
    p3_a23 := rosetta_g_miss_num_map(ddx_customer_profile_rec.discount_grace_days);
    p3_a24 := rosetta_g_miss_num_map(ddx_customer_profile_rec.statement_cycle_id);
    p3_a25 := ddx_customer_profile_rec.account_status;
    p3_a26 := rosetta_g_miss_num_map(ddx_customer_profile_rec.percent_collectable);
    p3_a27 := rosetta_g_miss_num_map(ddx_customer_profile_rec.autocash_hierarchy_id);
    p3_a28 := ddx_customer_profile_rec.attribute_category;
    p3_a29 := ddx_customer_profile_rec.attribute1;
    p3_a30 := ddx_customer_profile_rec.attribute2;
    p3_a31 := ddx_customer_profile_rec.attribute3;
    p3_a32 := ddx_customer_profile_rec.attribute4;
    p3_a33 := ddx_customer_profile_rec.attribute5;
    p3_a34 := ddx_customer_profile_rec.attribute6;
    p3_a35 := ddx_customer_profile_rec.attribute7;
    p3_a36 := ddx_customer_profile_rec.attribute8;
    p3_a37 := ddx_customer_profile_rec.attribute9;
    p3_a38 := ddx_customer_profile_rec.attribute10;
    p3_a39 := ddx_customer_profile_rec.attribute11;
    p3_a40 := ddx_customer_profile_rec.attribute12;
    p3_a41 := ddx_customer_profile_rec.attribute13;
    p3_a42 := ddx_customer_profile_rec.attribute14;
    p3_a43 := ddx_customer_profile_rec.attribute15;
    p3_a44 := ddx_customer_profile_rec.auto_rec_incl_disputed_flag;
    p3_a45 := ddx_customer_profile_rec.tax_printing_option;
    p3_a46 := ddx_customer_profile_rec.charge_on_finance_charge_flag;
    p3_a47 := rosetta_g_miss_num_map(ddx_customer_profile_rec.grouping_rule_id);
    p3_a48 := rosetta_g_miss_num_map(ddx_customer_profile_rec.clearing_days);
    p3_a49 := ddx_customer_profile_rec.jgzz_attribute_category;
    p3_a50 := ddx_customer_profile_rec.jgzz_attribute1;
    p3_a51 := ddx_customer_profile_rec.jgzz_attribute2;
    p3_a52 := ddx_customer_profile_rec.jgzz_attribute3;
    p3_a53 := ddx_customer_profile_rec.jgzz_attribute4;
    p3_a54 := ddx_customer_profile_rec.jgzz_attribute5;
    p3_a55 := ddx_customer_profile_rec.jgzz_attribute6;
    p3_a56 := ddx_customer_profile_rec.jgzz_attribute7;
    p3_a57 := ddx_customer_profile_rec.jgzz_attribute8;
    p3_a58 := ddx_customer_profile_rec.jgzz_attribute9;
    p3_a59 := ddx_customer_profile_rec.jgzz_attribute10;
    p3_a60 := ddx_customer_profile_rec.jgzz_attribute11;
    p3_a61 := ddx_customer_profile_rec.jgzz_attribute12;
    p3_a62 := ddx_customer_profile_rec.jgzz_attribute13;
    p3_a63 := ddx_customer_profile_rec.jgzz_attribute14;
    p3_a64 := ddx_customer_profile_rec.jgzz_attribute15;
    p3_a65 := ddx_customer_profile_rec.global_attribute1;
    p3_a66 := ddx_customer_profile_rec.global_attribute2;
    p3_a67 := ddx_customer_profile_rec.global_attribute3;
    p3_a68 := ddx_customer_profile_rec.global_attribute4;
    p3_a69 := ddx_customer_profile_rec.global_attribute5;
    p3_a70 := ddx_customer_profile_rec.global_attribute6;
    p3_a71 := ddx_customer_profile_rec.global_attribute7;
    p3_a72 := ddx_customer_profile_rec.global_attribute8;
    p3_a73 := ddx_customer_profile_rec.global_attribute9;
    p3_a74 := ddx_customer_profile_rec.global_attribute10;
    p3_a75 := ddx_customer_profile_rec.global_attribute11;
    p3_a76 := ddx_customer_profile_rec.global_attribute12;
    p3_a77 := ddx_customer_profile_rec.global_attribute13;
    p3_a78 := ddx_customer_profile_rec.global_attribute14;
    p3_a79 := ddx_customer_profile_rec.global_attribute15;
    p3_a80 := ddx_customer_profile_rec.global_attribute16;
    p3_a81 := ddx_customer_profile_rec.global_attribute17;
    p3_a82 := ddx_customer_profile_rec.global_attribute18;
    p3_a83 := ddx_customer_profile_rec.global_attribute19;
    p3_a84 := ddx_customer_profile_rec.global_attribute20;
    p3_a85 := ddx_customer_profile_rec.global_attribute_category;
    p3_a86 := ddx_customer_profile_rec.cons_inv_flag;
    p3_a87 := ddx_customer_profile_rec.cons_inv_type;
    p3_a88 := rosetta_g_miss_num_map(ddx_customer_profile_rec.autocash_hierarchy_id_for_adr);
    p3_a89 := ddx_customer_profile_rec.lockbox_matching_option;
    p3_a90 := ddx_customer_profile_rec.created_by_module;
    p3_a91 := rosetta_g_miss_num_map(ddx_customer_profile_rec.application_id);
    p3_a92 := ddx_customer_profile_rec.review_cycle;
    p3_a93 := ddx_customer_profile_rec.last_credit_review_date;
    p3_a94 := rosetta_g_miss_num_map(ddx_customer_profile_rec.party_id);
    p3_a95 := ddx_customer_profile_rec.credit_classification;
    p3_a96 := ddx_customer_profile_rec.cons_bill_level;
    p3_a97 := ddx_customer_profile_rec.late_charge_calculation_trx;
    p3_a98 := ddx_customer_profile_rec.credit_items_flag;
    p3_a99 := ddx_customer_profile_rec.disputed_transactions_flag;
    p3_a100 := ddx_customer_profile_rec.late_charge_type;
    p3_a101 := rosetta_g_miss_num_map(ddx_customer_profile_rec.late_charge_term_id);
    p3_a102 := ddx_customer_profile_rec.interest_calculation_period;
    p3_a103 := ddx_customer_profile_rec.hold_charged_invoices_flag;
    p3_a104 := rosetta_g_miss_num_map(ddx_customer_profile_rec.message_text_id);
    p3_a105 := ddx_customer_profile_rec.multiple_interest_rates_flag;
    p3_a106 := ddx_customer_profile_rec.charge_begin_date;



  end;

  procedure create_cust_acct_relate_5(p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  NUMBER := null
    , p1_a26  NUMBER := null
    , p1_a27  NUMBER := null
  )
  as
    ddp_cust_acct_relate_rec hz_cust_account_v2pub.cust_acct_relate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_acct_relate_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_acct_relate_rec.related_cust_account_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_acct_relate_rec.relationship_type := p1_a2;
    ddp_cust_acct_relate_rec.comments := p1_a3;
    ddp_cust_acct_relate_rec.attribute_category := p1_a4;
    ddp_cust_acct_relate_rec.attribute1 := p1_a5;
    ddp_cust_acct_relate_rec.attribute2 := p1_a6;
    ddp_cust_acct_relate_rec.attribute3 := p1_a7;
    ddp_cust_acct_relate_rec.attribute4 := p1_a8;
    ddp_cust_acct_relate_rec.attribute5 := p1_a9;
    ddp_cust_acct_relate_rec.attribute6 := p1_a10;
    ddp_cust_acct_relate_rec.attribute7 := p1_a11;
    ddp_cust_acct_relate_rec.attribute8 := p1_a12;
    ddp_cust_acct_relate_rec.attribute9 := p1_a13;
    ddp_cust_acct_relate_rec.attribute10 := p1_a14;
    ddp_cust_acct_relate_rec.customer_reciprocal_flag := p1_a15;
    ddp_cust_acct_relate_rec.status := p1_a16;
    ddp_cust_acct_relate_rec.attribute11 := p1_a17;
    ddp_cust_acct_relate_rec.attribute12 := p1_a18;
    ddp_cust_acct_relate_rec.attribute13 := p1_a19;
    ddp_cust_acct_relate_rec.attribute14 := p1_a20;
    ddp_cust_acct_relate_rec.attribute15 := p1_a21;
    ddp_cust_acct_relate_rec.bill_to_flag := p1_a22;
    ddp_cust_acct_relate_rec.ship_to_flag := p1_a23;
    ddp_cust_acct_relate_rec.created_by_module := p1_a24;
    ddp_cust_acct_relate_rec.application_id := rosetta_g_miss_num_map(p1_a25);
    ddp_cust_acct_relate_rec.org_id := rosetta_g_miss_num_map(p1_a26);
    ddp_cust_acct_relate_rec.cust_acct_relate_id := rosetta_g_miss_num_map(p1_a27);




    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.create_cust_acct_relate(p_init_msg_list,
      ddp_cust_acct_relate_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any




  end;

  procedure create_cust_acct_relate_6(p_init_msg_list  VARCHAR2
    , x_cust_acct_relate_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  NUMBER := null
    , p1_a26  NUMBER := null
    , p1_a27  NUMBER := null
  )
  as
    ddp_cust_acct_relate_rec hz_cust_account_v2pub.cust_acct_relate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_acct_relate_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_acct_relate_rec.related_cust_account_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_acct_relate_rec.relationship_type := p1_a2;
    ddp_cust_acct_relate_rec.comments := p1_a3;
    ddp_cust_acct_relate_rec.attribute_category := p1_a4;
    ddp_cust_acct_relate_rec.attribute1 := p1_a5;
    ddp_cust_acct_relate_rec.attribute2 := p1_a6;
    ddp_cust_acct_relate_rec.attribute3 := p1_a7;
    ddp_cust_acct_relate_rec.attribute4 := p1_a8;
    ddp_cust_acct_relate_rec.attribute5 := p1_a9;
    ddp_cust_acct_relate_rec.attribute6 := p1_a10;
    ddp_cust_acct_relate_rec.attribute7 := p1_a11;
    ddp_cust_acct_relate_rec.attribute8 := p1_a12;
    ddp_cust_acct_relate_rec.attribute9 := p1_a13;
    ddp_cust_acct_relate_rec.attribute10 := p1_a14;
    ddp_cust_acct_relate_rec.customer_reciprocal_flag := p1_a15;
    ddp_cust_acct_relate_rec.status := p1_a16;
    ddp_cust_acct_relate_rec.attribute11 := p1_a17;
    ddp_cust_acct_relate_rec.attribute12 := p1_a18;
    ddp_cust_acct_relate_rec.attribute13 := p1_a19;
    ddp_cust_acct_relate_rec.attribute14 := p1_a20;
    ddp_cust_acct_relate_rec.attribute15 := p1_a21;
    ddp_cust_acct_relate_rec.bill_to_flag := p1_a22;
    ddp_cust_acct_relate_rec.ship_to_flag := p1_a23;
    ddp_cust_acct_relate_rec.created_by_module := p1_a24;
    ddp_cust_acct_relate_rec.application_id := rosetta_g_miss_num_map(p1_a25);
    ddp_cust_acct_relate_rec.org_id := rosetta_g_miss_num_map(p1_a26);
    ddp_cust_acct_relate_rec.cust_acct_relate_id := rosetta_g_miss_num_map(p1_a27);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.create_cust_acct_relate(p_init_msg_list,
      ddp_cust_acct_relate_rec,
      x_cust_acct_relate_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_cust_acct_relate_7(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  NUMBER := null
    , p1_a26  NUMBER := null
    , p1_a27  NUMBER := null
  )
  as
    ddp_cust_acct_relate_rec hz_cust_account_v2pub.cust_acct_relate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_acct_relate_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_acct_relate_rec.related_cust_account_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_acct_relate_rec.relationship_type := p1_a2;
    ddp_cust_acct_relate_rec.comments := p1_a3;
    ddp_cust_acct_relate_rec.attribute_category := p1_a4;
    ddp_cust_acct_relate_rec.attribute1 := p1_a5;
    ddp_cust_acct_relate_rec.attribute2 := p1_a6;
    ddp_cust_acct_relate_rec.attribute3 := p1_a7;
    ddp_cust_acct_relate_rec.attribute4 := p1_a8;
    ddp_cust_acct_relate_rec.attribute5 := p1_a9;
    ddp_cust_acct_relate_rec.attribute6 := p1_a10;
    ddp_cust_acct_relate_rec.attribute7 := p1_a11;
    ddp_cust_acct_relate_rec.attribute8 := p1_a12;
    ddp_cust_acct_relate_rec.attribute9 := p1_a13;
    ddp_cust_acct_relate_rec.attribute10 := p1_a14;
    ddp_cust_acct_relate_rec.customer_reciprocal_flag := p1_a15;
    ddp_cust_acct_relate_rec.status := p1_a16;
    ddp_cust_acct_relate_rec.attribute11 := p1_a17;
    ddp_cust_acct_relate_rec.attribute12 := p1_a18;
    ddp_cust_acct_relate_rec.attribute13 := p1_a19;
    ddp_cust_acct_relate_rec.attribute14 := p1_a20;
    ddp_cust_acct_relate_rec.attribute15 := p1_a21;
    ddp_cust_acct_relate_rec.bill_to_flag := p1_a22;
    ddp_cust_acct_relate_rec.ship_to_flag := p1_a23;
    ddp_cust_acct_relate_rec.created_by_module := p1_a24;
    ddp_cust_acct_relate_rec.application_id := rosetta_g_miss_num_map(p1_a25);
    ddp_cust_acct_relate_rec.org_id := rosetta_g_miss_num_map(p1_a26);
    ddp_cust_acct_relate_rec.cust_acct_relate_id := rosetta_g_miss_num_map(p1_a27);





    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.update_cust_acct_relate(p_init_msg_list,
      ddp_cust_acct_relate_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_cust_acct_relate_8(p_init_msg_list  VARCHAR2
    , p_rowid  ROWID
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  VARCHAR2 := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
    , p1_a25  NUMBER := null
    , p1_a26  NUMBER := null
    , p1_a27  NUMBER := null
  )
  as
    ddp_cust_acct_relate_rec hz_cust_account_v2pub.cust_acct_relate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_acct_relate_rec.cust_account_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_acct_relate_rec.related_cust_account_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_acct_relate_rec.relationship_type := p1_a2;
    ddp_cust_acct_relate_rec.comments := p1_a3;
    ddp_cust_acct_relate_rec.attribute_category := p1_a4;
    ddp_cust_acct_relate_rec.attribute1 := p1_a5;
    ddp_cust_acct_relate_rec.attribute2 := p1_a6;
    ddp_cust_acct_relate_rec.attribute3 := p1_a7;
    ddp_cust_acct_relate_rec.attribute4 := p1_a8;
    ddp_cust_acct_relate_rec.attribute5 := p1_a9;
    ddp_cust_acct_relate_rec.attribute6 := p1_a10;
    ddp_cust_acct_relate_rec.attribute7 := p1_a11;
    ddp_cust_acct_relate_rec.attribute8 := p1_a12;
    ddp_cust_acct_relate_rec.attribute9 := p1_a13;
    ddp_cust_acct_relate_rec.attribute10 := p1_a14;
    ddp_cust_acct_relate_rec.customer_reciprocal_flag := p1_a15;
    ddp_cust_acct_relate_rec.status := p1_a16;
    ddp_cust_acct_relate_rec.attribute11 := p1_a17;
    ddp_cust_acct_relate_rec.attribute12 := p1_a18;
    ddp_cust_acct_relate_rec.attribute13 := p1_a19;
    ddp_cust_acct_relate_rec.attribute14 := p1_a20;
    ddp_cust_acct_relate_rec.attribute15 := p1_a21;
    ddp_cust_acct_relate_rec.bill_to_flag := p1_a22;
    ddp_cust_acct_relate_rec.ship_to_flag := p1_a23;
    ddp_cust_acct_relate_rec.created_by_module := p1_a24;
    ddp_cust_acct_relate_rec.application_id := rosetta_g_miss_num_map(p1_a25);
    ddp_cust_acct_relate_rec.org_id := rosetta_g_miss_num_map(p1_a26);
    ddp_cust_acct_relate_rec.cust_acct_relate_id := rosetta_g_miss_num_map(p1_a27);






    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.update_cust_acct_relate(p_init_msg_list,
      ddp_cust_acct_relate_rec,
      p_rowid,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure get_cust_acct_relate_rec_9(p_init_msg_list  VARCHAR2
    , p_cust_account_id  NUMBER
    , p_related_cust_account_id  NUMBER
    , p_cust_acct_relate_id  NUMBER
    , p_rowid  ROWID
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  VARCHAR2
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  VARCHAR2
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_cust_acct_relate_rec hz_cust_account_v2pub.cust_acct_relate_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    hz_cust_account_v2pub.get_cust_acct_relate_rec(p_init_msg_list,
      p_cust_account_id,
      p_related_cust_account_id,
      p_cust_acct_relate_id,
      p_rowid,
      ddx_cust_acct_relate_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddx_cust_acct_relate_rec.cust_account_id);
    p5_a1 := rosetta_g_miss_num_map(ddx_cust_acct_relate_rec.related_cust_account_id);
    p5_a2 := ddx_cust_acct_relate_rec.relationship_type;
    p5_a3 := ddx_cust_acct_relate_rec.comments;
    p5_a4 := ddx_cust_acct_relate_rec.attribute_category;
    p5_a5 := ddx_cust_acct_relate_rec.attribute1;
    p5_a6 := ddx_cust_acct_relate_rec.attribute2;
    p5_a7 := ddx_cust_acct_relate_rec.attribute3;
    p5_a8 := ddx_cust_acct_relate_rec.attribute4;
    p5_a9 := ddx_cust_acct_relate_rec.attribute5;
    p5_a10 := ddx_cust_acct_relate_rec.attribute6;
    p5_a11 := ddx_cust_acct_relate_rec.attribute7;
    p5_a12 := ddx_cust_acct_relate_rec.attribute8;
    p5_a13 := ddx_cust_acct_relate_rec.attribute9;
    p5_a14 := ddx_cust_acct_relate_rec.attribute10;
    p5_a15 := ddx_cust_acct_relate_rec.customer_reciprocal_flag;
    p5_a16 := ddx_cust_acct_relate_rec.status;
    p5_a17 := ddx_cust_acct_relate_rec.attribute11;
    p5_a18 := ddx_cust_acct_relate_rec.attribute12;
    p5_a19 := ddx_cust_acct_relate_rec.attribute13;
    p5_a20 := ddx_cust_acct_relate_rec.attribute14;
    p5_a21 := ddx_cust_acct_relate_rec.attribute15;
    p5_a22 := ddx_cust_acct_relate_rec.bill_to_flag;
    p5_a23 := ddx_cust_acct_relate_rec.ship_to_flag;
    p5_a24 := ddx_cust_acct_relate_rec.created_by_module;
    p5_a25 := rosetta_g_miss_num_map(ddx_cust_acct_relate_rec.application_id);
    p5_a26 := rosetta_g_miss_num_map(ddx_cust_acct_relate_rec.org_id);
    p5_a27 := rosetta_g_miss_num_map(ddx_cust_acct_relate_rec.cust_acct_relate_id);



  end;

end hz_cust_account_v2pub_jw;

/
