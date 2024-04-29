--------------------------------------------------------
--  DDL for Package Body HZ_CUSTOMER_PROFILE_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUSTOMER_PROFILE_V2PUB_JW" as
  /* $Header: ARH2CFJB.pls 120.5.12010000.2 2009/02/27 12:32:27 rgokavar ship $ */
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

  function next_review_date_compute_1(p_review_cycle  VARCHAR2
    , p_last_review_date  date
    , p_next_review_date  date
  ) return date
  as
    ddp_last_review_date date;
    ddp_next_review_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_last_review_date := rosetta_g_miss_date_in_map(p_last_review_date);

    ddp_next_review_date := rosetta_g_miss_date_in_map(p_next_review_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := hz_customer_profile_v2pub.next_review_date_compute(p_review_cycle,
      ddp_last_review_date,
      ddp_next_review_date);

    -- copy data back from the local OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  function last_review_date_default_2(p_review_cycle  VARCHAR2
    , p_last_review_date  date
    , p_create_update_flag  VARCHAR2
  ) return date
  as
    ddp_last_review_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_last_review_date := rosetta_g_miss_date_in_map(p_last_review_date);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := hz_customer_profile_v2pub.last_review_date_default(p_review_cycle,
      ddp_last_review_date,
      p_create_update_flag);

    -- copy data back from the local OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  procedure create_customer_profile_3(p_init_msg_list  VARCHAR2
    , p_create_profile_amt  VARCHAR2
    , x_cust_account_profile_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  DATE := null
    , p1_a7  NUMBER := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  NUMBER := null
    , p1_a15  NUMBER := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  NUMBER := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
    , p1_a21  NUMBER := null
    , p1_a22  NUMBER := null
    , p1_a23  NUMBER := null
    , p1_a24  NUMBER := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  NUMBER := null
    , p1_a27  NUMBER := null
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
    , p1_a47  NUMBER := null
    , p1_a48  NUMBER := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  NUMBER := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  NUMBER := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  DATE := null
    , p1_a94  NUMBER := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  NUMBER := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  NUMBER := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  DATE := null
    , p1_a107  NUMBER := null
  )
  as
    ddp_customer_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_customer_profile_rec.cust_account_profile_id := rosetta_g_miss_num_map(p1_a0);
    ddp_customer_profile_rec.cust_account_id := rosetta_g_miss_num_map(p1_a1);
    ddp_customer_profile_rec.status := p1_a2;
    ddp_customer_profile_rec.collector_id := rosetta_g_miss_num_map(p1_a3);
    ddp_customer_profile_rec.credit_analyst_id := rosetta_g_miss_num_map(p1_a4);
    ddp_customer_profile_rec.credit_checking := p1_a5;
    ddp_customer_profile_rec.next_credit_review_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_customer_profile_rec.tolerance := rosetta_g_miss_num_map(p1_a7);
    ddp_customer_profile_rec.discount_terms := p1_a8;
    ddp_customer_profile_rec.dunning_letters := p1_a9;
    ddp_customer_profile_rec.interest_charges := p1_a10;
    ddp_customer_profile_rec.send_statements := p1_a11;
    ddp_customer_profile_rec.credit_balance_statements := p1_a12;
    ddp_customer_profile_rec.credit_hold := p1_a13;
    ddp_customer_profile_rec.profile_class_id := rosetta_g_miss_num_map(p1_a14);
    ddp_customer_profile_rec.site_use_id := rosetta_g_miss_num_map(p1_a15);
    ddp_customer_profile_rec.credit_rating := p1_a16;
    ddp_customer_profile_rec.risk_code := p1_a17;
    ddp_customer_profile_rec.standard_terms := rosetta_g_miss_num_map(p1_a18);
    ddp_customer_profile_rec.override_terms := p1_a19;
    ddp_customer_profile_rec.dunning_letter_set_id := rosetta_g_miss_num_map(p1_a20);
    ddp_customer_profile_rec.interest_period_days := rosetta_g_miss_num_map(p1_a21);
    ddp_customer_profile_rec.payment_grace_days := rosetta_g_miss_num_map(p1_a22);
    ddp_customer_profile_rec.discount_grace_days := rosetta_g_miss_num_map(p1_a23);
    ddp_customer_profile_rec.statement_cycle_id := rosetta_g_miss_num_map(p1_a24);
    ddp_customer_profile_rec.account_status := p1_a25;
    ddp_customer_profile_rec.percent_collectable := rosetta_g_miss_num_map(p1_a26);
    ddp_customer_profile_rec.autocash_hierarchy_id := rosetta_g_miss_num_map(p1_a27);
    ddp_customer_profile_rec.attribute_category := p1_a28;
    ddp_customer_profile_rec.attribute1 := p1_a29;
    ddp_customer_profile_rec.attribute2 := p1_a30;
    ddp_customer_profile_rec.attribute3 := p1_a31;
    ddp_customer_profile_rec.attribute4 := p1_a32;
    ddp_customer_profile_rec.attribute5 := p1_a33;
    ddp_customer_profile_rec.attribute6 := p1_a34;
    ddp_customer_profile_rec.attribute7 := p1_a35;
    ddp_customer_profile_rec.attribute8 := p1_a36;
    ddp_customer_profile_rec.attribute9 := p1_a37;
    ddp_customer_profile_rec.attribute10 := p1_a38;
    ddp_customer_profile_rec.attribute11 := p1_a39;
    ddp_customer_profile_rec.attribute12 := p1_a40;
    ddp_customer_profile_rec.attribute13 := p1_a41;
    ddp_customer_profile_rec.attribute14 := p1_a42;
    ddp_customer_profile_rec.attribute15 := p1_a43;
    ddp_customer_profile_rec.auto_rec_incl_disputed_flag := p1_a44;
    ddp_customer_profile_rec.tax_printing_option := p1_a45;
    ddp_customer_profile_rec.charge_on_finance_charge_flag := p1_a46;
    ddp_customer_profile_rec.grouping_rule_id := rosetta_g_miss_num_map(p1_a47);
    ddp_customer_profile_rec.clearing_days := rosetta_g_miss_num_map(p1_a48);
    ddp_customer_profile_rec.jgzz_attribute_category := p1_a49;
    ddp_customer_profile_rec.jgzz_attribute1 := p1_a50;
    ddp_customer_profile_rec.jgzz_attribute2 := p1_a51;
    ddp_customer_profile_rec.jgzz_attribute3 := p1_a52;
    ddp_customer_profile_rec.jgzz_attribute4 := p1_a53;
    ddp_customer_profile_rec.jgzz_attribute5 := p1_a54;
    ddp_customer_profile_rec.jgzz_attribute6 := p1_a55;
    ddp_customer_profile_rec.jgzz_attribute7 := p1_a56;
    ddp_customer_profile_rec.jgzz_attribute8 := p1_a57;
    ddp_customer_profile_rec.jgzz_attribute9 := p1_a58;
    ddp_customer_profile_rec.jgzz_attribute10 := p1_a59;
    ddp_customer_profile_rec.jgzz_attribute11 := p1_a60;
    ddp_customer_profile_rec.jgzz_attribute12 := p1_a61;
    ddp_customer_profile_rec.jgzz_attribute13 := p1_a62;
    ddp_customer_profile_rec.jgzz_attribute14 := p1_a63;
    ddp_customer_profile_rec.jgzz_attribute15 := p1_a64;
    ddp_customer_profile_rec.global_attribute1 := p1_a65;
    ddp_customer_profile_rec.global_attribute2 := p1_a66;
    ddp_customer_profile_rec.global_attribute3 := p1_a67;
    ddp_customer_profile_rec.global_attribute4 := p1_a68;
    ddp_customer_profile_rec.global_attribute5 := p1_a69;
    ddp_customer_profile_rec.global_attribute6 := p1_a70;
    ddp_customer_profile_rec.global_attribute7 := p1_a71;
    ddp_customer_profile_rec.global_attribute8 := p1_a72;
    ddp_customer_profile_rec.global_attribute9 := p1_a73;
    ddp_customer_profile_rec.global_attribute10 := p1_a74;
    ddp_customer_profile_rec.global_attribute11 := p1_a75;
    ddp_customer_profile_rec.global_attribute12 := p1_a76;
    ddp_customer_profile_rec.global_attribute13 := p1_a77;
    ddp_customer_profile_rec.global_attribute14 := p1_a78;
    ddp_customer_profile_rec.global_attribute15 := p1_a79;
    ddp_customer_profile_rec.global_attribute16 := p1_a80;
    ddp_customer_profile_rec.global_attribute17 := p1_a81;
    ddp_customer_profile_rec.global_attribute18 := p1_a82;
    ddp_customer_profile_rec.global_attribute19 := p1_a83;
    ddp_customer_profile_rec.global_attribute20 := p1_a84;
    ddp_customer_profile_rec.global_attribute_category := p1_a85;
    ddp_customer_profile_rec.cons_inv_flag := p1_a86;
    ddp_customer_profile_rec.cons_inv_type := p1_a87;
    ddp_customer_profile_rec.autocash_hierarchy_id_for_adr := rosetta_g_miss_num_map(p1_a88);
    ddp_customer_profile_rec.lockbox_matching_option := p1_a89;
    ddp_customer_profile_rec.created_by_module := p1_a90;
    ddp_customer_profile_rec.application_id := rosetta_g_miss_num_map(p1_a91);
    ddp_customer_profile_rec.review_cycle := p1_a92;
    ddp_customer_profile_rec.last_credit_review_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_customer_profile_rec.party_id := rosetta_g_miss_num_map(p1_a94);
    ddp_customer_profile_rec.credit_classification := p1_a95;
    ddp_customer_profile_rec.cons_bill_level := p1_a96;
    ddp_customer_profile_rec.late_charge_calculation_trx := p1_a97;
    ddp_customer_profile_rec.credit_items_flag := p1_a98;
    ddp_customer_profile_rec.disputed_transactions_flag := p1_a99;
    ddp_customer_profile_rec.late_charge_type := p1_a100;
    ddp_customer_profile_rec.late_charge_term_id := rosetta_g_miss_num_map(p1_a101);
    ddp_customer_profile_rec.interest_calculation_period := p1_a102;
    ddp_customer_profile_rec.hold_charged_invoices_flag := p1_a103;
    ddp_customer_profile_rec.message_text_id := rosetta_g_miss_num_map(p1_a104);
    ddp_customer_profile_rec.multiple_interest_rates_flag := p1_a105;
    ddp_customer_profile_rec.charge_begin_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_customer_profile_rec.automatch_set_id  := rosetta_g_miss_num_map(p1_a107);




    -- here's the delegated call to the old PL/SQL routine
    hz_customer_profile_v2pub.create_customer_profile(p_init_msg_list,
      ddp_customer_profile_rec,
      p_create_profile_amt,
      x_cust_account_profile_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_customer_profile_4(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  DATE := null
    , p1_a7  NUMBER := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  NUMBER := null
    , p1_a15  NUMBER := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  NUMBER := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  NUMBER := null
    , p1_a21  NUMBER := null
    , p1_a22  NUMBER := null
    , p1_a23  NUMBER := null
    , p1_a24  NUMBER := null
    , p1_a25  VARCHAR2 := null
    , p1_a26  NUMBER := null
    , p1_a27  NUMBER := null
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
    , p1_a47  NUMBER := null
    , p1_a48  NUMBER := null
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  VARCHAR2 := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  VARCHAR2 := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  VARCHAR2 := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  VARCHAR2 := null
    , p1_a78  VARCHAR2 := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  VARCHAR2 := null
    , p1_a81  VARCHAR2 := null
    , p1_a82  VARCHAR2 := null
    , p1_a83  VARCHAR2 := null
    , p1_a84  VARCHAR2 := null
    , p1_a85  VARCHAR2 := null
    , p1_a86  VARCHAR2 := null
    , p1_a87  VARCHAR2 := null
    , p1_a88  NUMBER := null
    , p1_a89  VARCHAR2 := null
    , p1_a90  VARCHAR2 := null
    , p1_a91  NUMBER := null
    , p1_a92  VARCHAR2 := null
    , p1_a93  DATE := null
    , p1_a94  NUMBER := null
    , p1_a95  VARCHAR2 := null
    , p1_a96  VARCHAR2 := null
    , p1_a97  VARCHAR2 := null
    , p1_a98  VARCHAR2 := null
    , p1_a99  VARCHAR2 := null
    , p1_a100  VARCHAR2 := null
    , p1_a101  NUMBER := null
    , p1_a102  VARCHAR2 := null
    , p1_a103  VARCHAR2 := null
    , p1_a104  NUMBER := null
    , p1_a105  VARCHAR2 := null
    , p1_a106  DATE := null
    , p1_a107  NUMBER := null
  )
  as
    ddp_customer_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_customer_profile_rec.cust_account_profile_id := rosetta_g_miss_num_map(p1_a0);
    ddp_customer_profile_rec.cust_account_id := rosetta_g_miss_num_map(p1_a1);
    ddp_customer_profile_rec.status := p1_a2;
    ddp_customer_profile_rec.collector_id := rosetta_g_miss_num_map(p1_a3);
    ddp_customer_profile_rec.credit_analyst_id := rosetta_g_miss_num_map(p1_a4);
    ddp_customer_profile_rec.credit_checking := p1_a5;
    ddp_customer_profile_rec.next_credit_review_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_customer_profile_rec.tolerance := rosetta_g_miss_num_map(p1_a7);
    ddp_customer_profile_rec.discount_terms := p1_a8;
    ddp_customer_profile_rec.dunning_letters := p1_a9;
    ddp_customer_profile_rec.interest_charges := p1_a10;
    ddp_customer_profile_rec.send_statements := p1_a11;
    ddp_customer_profile_rec.credit_balance_statements := p1_a12;
    ddp_customer_profile_rec.credit_hold := p1_a13;
    ddp_customer_profile_rec.profile_class_id := rosetta_g_miss_num_map(p1_a14);
    ddp_customer_profile_rec.site_use_id := rosetta_g_miss_num_map(p1_a15);
    ddp_customer_profile_rec.credit_rating := p1_a16;
    ddp_customer_profile_rec.risk_code := p1_a17;
    ddp_customer_profile_rec.standard_terms := rosetta_g_miss_num_map(p1_a18);
    ddp_customer_profile_rec.override_terms := p1_a19;
    ddp_customer_profile_rec.dunning_letter_set_id := rosetta_g_miss_num_map(p1_a20);
    ddp_customer_profile_rec.interest_period_days := rosetta_g_miss_num_map(p1_a21);
    ddp_customer_profile_rec.payment_grace_days := rosetta_g_miss_num_map(p1_a22);
    ddp_customer_profile_rec.discount_grace_days := rosetta_g_miss_num_map(p1_a23);
    ddp_customer_profile_rec.statement_cycle_id := rosetta_g_miss_num_map(p1_a24);
    ddp_customer_profile_rec.account_status := p1_a25;
    ddp_customer_profile_rec.percent_collectable := rosetta_g_miss_num_map(p1_a26);
    ddp_customer_profile_rec.autocash_hierarchy_id := rosetta_g_miss_num_map(p1_a27);
    ddp_customer_profile_rec.attribute_category := p1_a28;
    ddp_customer_profile_rec.attribute1 := p1_a29;
    ddp_customer_profile_rec.attribute2 := p1_a30;
    ddp_customer_profile_rec.attribute3 := p1_a31;
    ddp_customer_profile_rec.attribute4 := p1_a32;
    ddp_customer_profile_rec.attribute5 := p1_a33;
    ddp_customer_profile_rec.attribute6 := p1_a34;
    ddp_customer_profile_rec.attribute7 := p1_a35;
    ddp_customer_profile_rec.attribute8 := p1_a36;
    ddp_customer_profile_rec.attribute9 := p1_a37;
    ddp_customer_profile_rec.attribute10 := p1_a38;
    ddp_customer_profile_rec.attribute11 := p1_a39;
    ddp_customer_profile_rec.attribute12 := p1_a40;
    ddp_customer_profile_rec.attribute13 := p1_a41;
    ddp_customer_profile_rec.attribute14 := p1_a42;
    ddp_customer_profile_rec.attribute15 := p1_a43;
    ddp_customer_profile_rec.auto_rec_incl_disputed_flag := p1_a44;
    ddp_customer_profile_rec.tax_printing_option := p1_a45;
    ddp_customer_profile_rec.charge_on_finance_charge_flag := p1_a46;
    ddp_customer_profile_rec.grouping_rule_id := rosetta_g_miss_num_map(p1_a47);
    ddp_customer_profile_rec.clearing_days := rosetta_g_miss_num_map(p1_a48);
    ddp_customer_profile_rec.jgzz_attribute_category := p1_a49;
    ddp_customer_profile_rec.jgzz_attribute1 := p1_a50;
    ddp_customer_profile_rec.jgzz_attribute2 := p1_a51;
    ddp_customer_profile_rec.jgzz_attribute3 := p1_a52;
    ddp_customer_profile_rec.jgzz_attribute4 := p1_a53;
    ddp_customer_profile_rec.jgzz_attribute5 := p1_a54;
    ddp_customer_profile_rec.jgzz_attribute6 := p1_a55;
    ddp_customer_profile_rec.jgzz_attribute7 := p1_a56;
    ddp_customer_profile_rec.jgzz_attribute8 := p1_a57;
    ddp_customer_profile_rec.jgzz_attribute9 := p1_a58;
    ddp_customer_profile_rec.jgzz_attribute10 := p1_a59;
    ddp_customer_profile_rec.jgzz_attribute11 := p1_a60;
    ddp_customer_profile_rec.jgzz_attribute12 := p1_a61;
    ddp_customer_profile_rec.jgzz_attribute13 := p1_a62;
    ddp_customer_profile_rec.jgzz_attribute14 := p1_a63;
    ddp_customer_profile_rec.jgzz_attribute15 := p1_a64;
    ddp_customer_profile_rec.global_attribute1 := p1_a65;
    ddp_customer_profile_rec.global_attribute2 := p1_a66;
    ddp_customer_profile_rec.global_attribute3 := p1_a67;
    ddp_customer_profile_rec.global_attribute4 := p1_a68;
    ddp_customer_profile_rec.global_attribute5 := p1_a69;
    ddp_customer_profile_rec.global_attribute6 := p1_a70;
    ddp_customer_profile_rec.global_attribute7 := p1_a71;
    ddp_customer_profile_rec.global_attribute8 := p1_a72;
    ddp_customer_profile_rec.global_attribute9 := p1_a73;
    ddp_customer_profile_rec.global_attribute10 := p1_a74;
    ddp_customer_profile_rec.global_attribute11 := p1_a75;
    ddp_customer_profile_rec.global_attribute12 := p1_a76;
    ddp_customer_profile_rec.global_attribute13 := p1_a77;
    ddp_customer_profile_rec.global_attribute14 := p1_a78;
    ddp_customer_profile_rec.global_attribute15 := p1_a79;
    ddp_customer_profile_rec.global_attribute16 := p1_a80;
    ddp_customer_profile_rec.global_attribute17 := p1_a81;
    ddp_customer_profile_rec.global_attribute18 := p1_a82;
    ddp_customer_profile_rec.global_attribute19 := p1_a83;
    ddp_customer_profile_rec.global_attribute20 := p1_a84;
    ddp_customer_profile_rec.global_attribute_category := p1_a85;
    ddp_customer_profile_rec.cons_inv_flag := p1_a86;
    ddp_customer_profile_rec.cons_inv_type := p1_a87;
    ddp_customer_profile_rec.autocash_hierarchy_id_for_adr := rosetta_g_miss_num_map(p1_a88);
    ddp_customer_profile_rec.lockbox_matching_option := p1_a89;
    ddp_customer_profile_rec.created_by_module := p1_a90;
    ddp_customer_profile_rec.application_id := rosetta_g_miss_num_map(p1_a91);
    ddp_customer_profile_rec.review_cycle := p1_a92;
    ddp_customer_profile_rec.last_credit_review_date := rosetta_g_miss_date_in_map(p1_a93);
    ddp_customer_profile_rec.party_id := rosetta_g_miss_num_map(p1_a94);
    ddp_customer_profile_rec.credit_classification := p1_a95;
    ddp_customer_profile_rec.cons_bill_level := p1_a96;
    ddp_customer_profile_rec.late_charge_calculation_trx := p1_a97;
    ddp_customer_profile_rec.credit_items_flag := p1_a98;
    ddp_customer_profile_rec.disputed_transactions_flag := p1_a99;
    ddp_customer_profile_rec.late_charge_type := p1_a100;
    ddp_customer_profile_rec.late_charge_term_id := rosetta_g_miss_num_map(p1_a101);
    ddp_customer_profile_rec.interest_calculation_period := p1_a102;
    ddp_customer_profile_rec.hold_charged_invoices_flag := p1_a103;
    ddp_customer_profile_rec.message_text_id := rosetta_g_miss_num_map(p1_a104);
    ddp_customer_profile_rec.multiple_interest_rates_flag := p1_a105;
    ddp_customer_profile_rec.charge_begin_date := rosetta_g_miss_date_in_map(p1_a106);
    ddp_customer_profile_rec.automatch_set_id  := rosetta_g_miss_num_map(p1_a107);




    -- here's the delegated call to the old PL/SQL routine
    hz_customer_profile_v2pub.update_customer_profile(p_init_msg_list,
      ddp_customer_profile_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_customer_profile_rec_5(p_init_msg_list  VARCHAR2
    , p_cust_account_profile_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  NUMBER
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  DATE
    , p2_a7 out nocopy  NUMBER
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  NUMBER
    , p2_a15 out nocopy  NUMBER
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  NUMBER
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  NUMBER
    , p2_a21 out nocopy  NUMBER
    , p2_a22 out nocopy  NUMBER
    , p2_a23 out nocopy  NUMBER
    , p2_a24 out nocopy  NUMBER
    , p2_a25 out nocopy  VARCHAR2
    , p2_a26 out nocopy  NUMBER
    , p2_a27 out nocopy  NUMBER
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
    , p2_a47 out nocopy  NUMBER
    , p2_a48 out nocopy  NUMBER
    , p2_a49 out nocopy  VARCHAR2
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  VARCHAR2
    , p2_a63 out nocopy  VARCHAR2
    , p2_a64 out nocopy  VARCHAR2
    , p2_a65 out nocopy  VARCHAR2
    , p2_a66 out nocopy  VARCHAR2
    , p2_a67 out nocopy  VARCHAR2
    , p2_a68 out nocopy  VARCHAR2
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  VARCHAR2
    , p2_a71 out nocopy  VARCHAR2
    , p2_a72 out nocopy  VARCHAR2
    , p2_a73 out nocopy  VARCHAR2
    , p2_a74 out nocopy  VARCHAR2
    , p2_a75 out nocopy  VARCHAR2
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  VARCHAR2
    , p2_a78 out nocopy  VARCHAR2
    , p2_a79 out nocopy  VARCHAR2
    , p2_a80 out nocopy  VARCHAR2
    , p2_a81 out nocopy  VARCHAR2
    , p2_a82 out nocopy  VARCHAR2
    , p2_a83 out nocopy  VARCHAR2
    , p2_a84 out nocopy  VARCHAR2
    , p2_a85 out nocopy  VARCHAR2
    , p2_a86 out nocopy  VARCHAR2
    , p2_a87 out nocopy  VARCHAR2
    , p2_a88 out nocopy  NUMBER
    , p2_a89 out nocopy  VARCHAR2
    , p2_a90 out nocopy  VARCHAR2
    , p2_a91 out nocopy  NUMBER
    , p2_a92 out nocopy  VARCHAR2
    , p2_a93 out nocopy  DATE
    , p2_a94 out nocopy  NUMBER
    , p2_a95 out nocopy  VARCHAR2
    , p2_a96 out nocopy  VARCHAR2
    , p2_a97 out nocopy  VARCHAR2
    , p2_a98 out nocopy  VARCHAR2
    , p2_a99 out nocopy  VARCHAR2
    , p2_a100 out nocopy  VARCHAR2
    , p2_a101 out nocopy  NUMBER
    , p2_a102 out nocopy  VARCHAR2
    , p2_a103 out nocopy  VARCHAR2
    , p2_a104 out nocopy  NUMBER
    , p2_a105 out nocopy  VARCHAR2
    , p2_a106 out nocopy  DATE
    , p2_a107 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_customer_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_customer_profile_v2pub.get_customer_profile_rec(p_init_msg_list,
      p_cust_account_profile_id,
      ddx_customer_profile_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_customer_profile_rec.cust_account_profile_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_customer_profile_rec.cust_account_id);
    p2_a2 := ddx_customer_profile_rec.status;
    p2_a3 := rosetta_g_miss_num_map(ddx_customer_profile_rec.collector_id);
    p2_a4 := rosetta_g_miss_num_map(ddx_customer_profile_rec.credit_analyst_id);
    p2_a5 := ddx_customer_profile_rec.credit_checking;
    p2_a6 := ddx_customer_profile_rec.next_credit_review_date;
    p2_a7 := rosetta_g_miss_num_map(ddx_customer_profile_rec.tolerance);
    p2_a8 := ddx_customer_profile_rec.discount_terms;
    p2_a9 := ddx_customer_profile_rec.dunning_letters;
    p2_a10 := ddx_customer_profile_rec.interest_charges;
    p2_a11 := ddx_customer_profile_rec.send_statements;
    p2_a12 := ddx_customer_profile_rec.credit_balance_statements;
    p2_a13 := ddx_customer_profile_rec.credit_hold;
    p2_a14 := rosetta_g_miss_num_map(ddx_customer_profile_rec.profile_class_id);
    p2_a15 := rosetta_g_miss_num_map(ddx_customer_profile_rec.site_use_id);
    p2_a16 := ddx_customer_profile_rec.credit_rating;
    p2_a17 := ddx_customer_profile_rec.risk_code;
    p2_a18 := rosetta_g_miss_num_map(ddx_customer_profile_rec.standard_terms);
    p2_a19 := ddx_customer_profile_rec.override_terms;
    p2_a20 := rosetta_g_miss_num_map(ddx_customer_profile_rec.dunning_letter_set_id);
    p2_a21 := rosetta_g_miss_num_map(ddx_customer_profile_rec.interest_period_days);
    p2_a22 := rosetta_g_miss_num_map(ddx_customer_profile_rec.payment_grace_days);
    p2_a23 := rosetta_g_miss_num_map(ddx_customer_profile_rec.discount_grace_days);
    p2_a24 := rosetta_g_miss_num_map(ddx_customer_profile_rec.statement_cycle_id);
    p2_a25 := ddx_customer_profile_rec.account_status;
    p2_a26 := rosetta_g_miss_num_map(ddx_customer_profile_rec.percent_collectable);
    p2_a27 := rosetta_g_miss_num_map(ddx_customer_profile_rec.autocash_hierarchy_id);
    p2_a28 := ddx_customer_profile_rec.attribute_category;
    p2_a29 := ddx_customer_profile_rec.attribute1;
    p2_a30 := ddx_customer_profile_rec.attribute2;
    p2_a31 := ddx_customer_profile_rec.attribute3;
    p2_a32 := ddx_customer_profile_rec.attribute4;
    p2_a33 := ddx_customer_profile_rec.attribute5;
    p2_a34 := ddx_customer_profile_rec.attribute6;
    p2_a35 := ddx_customer_profile_rec.attribute7;
    p2_a36 := ddx_customer_profile_rec.attribute8;
    p2_a37 := ddx_customer_profile_rec.attribute9;
    p2_a38 := ddx_customer_profile_rec.attribute10;
    p2_a39 := ddx_customer_profile_rec.attribute11;
    p2_a40 := ddx_customer_profile_rec.attribute12;
    p2_a41 := ddx_customer_profile_rec.attribute13;
    p2_a42 := ddx_customer_profile_rec.attribute14;
    p2_a43 := ddx_customer_profile_rec.attribute15;
    p2_a44 := ddx_customer_profile_rec.auto_rec_incl_disputed_flag;
    p2_a45 := ddx_customer_profile_rec.tax_printing_option;
    p2_a46 := ddx_customer_profile_rec.charge_on_finance_charge_flag;
    p2_a47 := rosetta_g_miss_num_map(ddx_customer_profile_rec.grouping_rule_id);
    p2_a48 := rosetta_g_miss_num_map(ddx_customer_profile_rec.clearing_days);
    p2_a49 := ddx_customer_profile_rec.jgzz_attribute_category;
    p2_a50 := ddx_customer_profile_rec.jgzz_attribute1;
    p2_a51 := ddx_customer_profile_rec.jgzz_attribute2;
    p2_a52 := ddx_customer_profile_rec.jgzz_attribute3;
    p2_a53 := ddx_customer_profile_rec.jgzz_attribute4;
    p2_a54 := ddx_customer_profile_rec.jgzz_attribute5;
    p2_a55 := ddx_customer_profile_rec.jgzz_attribute6;
    p2_a56 := ddx_customer_profile_rec.jgzz_attribute7;
    p2_a57 := ddx_customer_profile_rec.jgzz_attribute8;
    p2_a58 := ddx_customer_profile_rec.jgzz_attribute9;
    p2_a59 := ddx_customer_profile_rec.jgzz_attribute10;
    p2_a60 := ddx_customer_profile_rec.jgzz_attribute11;
    p2_a61 := ddx_customer_profile_rec.jgzz_attribute12;
    p2_a62 := ddx_customer_profile_rec.jgzz_attribute13;
    p2_a63 := ddx_customer_profile_rec.jgzz_attribute14;
    p2_a64 := ddx_customer_profile_rec.jgzz_attribute15;
    p2_a65 := ddx_customer_profile_rec.global_attribute1;
    p2_a66 := ddx_customer_profile_rec.global_attribute2;
    p2_a67 := ddx_customer_profile_rec.global_attribute3;
    p2_a68 := ddx_customer_profile_rec.global_attribute4;
    p2_a69 := ddx_customer_profile_rec.global_attribute5;
    p2_a70 := ddx_customer_profile_rec.global_attribute6;
    p2_a71 := ddx_customer_profile_rec.global_attribute7;
    p2_a72 := ddx_customer_profile_rec.global_attribute8;
    p2_a73 := ddx_customer_profile_rec.global_attribute9;
    p2_a74 := ddx_customer_profile_rec.global_attribute10;
    p2_a75 := ddx_customer_profile_rec.global_attribute11;
    p2_a76 := ddx_customer_profile_rec.global_attribute12;
    p2_a77 := ddx_customer_profile_rec.global_attribute13;
    p2_a78 := ddx_customer_profile_rec.global_attribute14;
    p2_a79 := ddx_customer_profile_rec.global_attribute15;
    p2_a80 := ddx_customer_profile_rec.global_attribute16;
    p2_a81 := ddx_customer_profile_rec.global_attribute17;
    p2_a82 := ddx_customer_profile_rec.global_attribute18;
    p2_a83 := ddx_customer_profile_rec.global_attribute19;
    p2_a84 := ddx_customer_profile_rec.global_attribute20;
    p2_a85 := ddx_customer_profile_rec.global_attribute_category;
    p2_a86 := ddx_customer_profile_rec.cons_inv_flag;
    p2_a87 := ddx_customer_profile_rec.cons_inv_type;
    p2_a88 := rosetta_g_miss_num_map(ddx_customer_profile_rec.autocash_hierarchy_id_for_adr);
    p2_a89 := ddx_customer_profile_rec.lockbox_matching_option;
    p2_a90 := ddx_customer_profile_rec.created_by_module;
    p2_a91 := rosetta_g_miss_num_map(ddx_customer_profile_rec.application_id);
    p2_a92 := ddx_customer_profile_rec.review_cycle;
    p2_a93 := ddx_customer_profile_rec.last_credit_review_date;
    p2_a94 := rosetta_g_miss_num_map(ddx_customer_profile_rec.party_id);
    p2_a95 := ddx_customer_profile_rec.credit_classification;
    p2_a96 := ddx_customer_profile_rec.cons_bill_level;
    p2_a97 := ddx_customer_profile_rec.late_charge_calculation_trx;
    p2_a98 := ddx_customer_profile_rec.credit_items_flag;
    p2_a99 := ddx_customer_profile_rec.disputed_transactions_flag;
    p2_a100 := ddx_customer_profile_rec.late_charge_type;
    p2_a101 := rosetta_g_miss_num_map(ddx_customer_profile_rec.late_charge_term_id);
    p2_a102 := ddx_customer_profile_rec.interest_calculation_period;
    p2_a103 := ddx_customer_profile_rec.hold_charged_invoices_flag;
    p2_a104 := rosetta_g_miss_num_map(ddx_customer_profile_rec.message_text_id);
    p2_a105 := ddx_customer_profile_rec.multiple_interest_rates_flag;
    p2_a106 := ddx_customer_profile_rec.charge_begin_date;
    p2_a107 := ddx_customer_profile_rec.automatch_set_id;


  end;

  procedure create_cust_profile_amt_6(p_init_msg_list  VARCHAR2
    , p_check_foreign_key  VARCHAR2
    , x_cust_acct_profile_amt_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := null
    , p2_a1  NUMBER := null
    , p2_a2  VARCHAR2 := null
    , p2_a3  NUMBER := null
    , p2_a4  NUMBER := null
    , p2_a5  NUMBER := null
    , p2_a6  NUMBER := null
    , p2_a7  NUMBER := null
    , p2_a8  NUMBER := null
    , p2_a9  NUMBER := null
    , p2_a10  NUMBER := null
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
    , p2_a26  VARCHAR2 := null
    , p2_a27  NUMBER := null
    , p2_a28  NUMBER := null
    , p2_a29  NUMBER := null
    , p2_a30  NUMBER := null
    , p2_a31  DATE := null
    , p2_a32  VARCHAR2 := null
    , p2_a33  VARCHAR2 := null
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
    , p2_a60  VARCHAR2 := null
    , p2_a61  VARCHAR2 := null
    , p2_a62  VARCHAR2 := null
    , p2_a63  VARCHAR2 := null
    , p2_a64  VARCHAR2 := null
    , p2_a65  VARCHAR2 := null
    , p2_a66  VARCHAR2 := null
    , p2_a67  VARCHAR2 := null
    , p2_a68  VARCHAR2 := null
    , p2_a69  VARCHAR2 := null
    , p2_a70  NUMBER := null
    , p2_a71  VARCHAR2 := null
    , p2_a72  VARCHAR2 := null
    , p2_a73  NUMBER := null
    , p2_a74  VARCHAR2 := null
    , p2_a75  NUMBER := null
    , p2_a76  VARCHAR2 := null
    , p2_a77  NUMBER := null
    , p2_a78  NUMBER := null
    , p2_a79  VARCHAR2 := null
    , p2_a80  NUMBER := null
    , p2_a81  NUMBER := null
    , p2_a82  NUMBER := null
    , p2_a83  NUMBER := null
  )
  as
    ddp_cust_profile_amt_rec hz_customer_profile_v2pub.cust_profile_amt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_cust_profile_amt_rec.cust_acct_profile_amt_id := rosetta_g_miss_num_map(p2_a0);
    ddp_cust_profile_amt_rec.cust_account_profile_id := rosetta_g_miss_num_map(p2_a1);
    ddp_cust_profile_amt_rec.currency_code := p2_a2;
    ddp_cust_profile_amt_rec.trx_credit_limit := rosetta_g_miss_num_map(p2_a3);
    ddp_cust_profile_amt_rec.overall_credit_limit := rosetta_g_miss_num_map(p2_a4);
    ddp_cust_profile_amt_rec.min_dunning_amount := rosetta_g_miss_num_map(p2_a5);
    ddp_cust_profile_amt_rec.min_dunning_invoice_amount := rosetta_g_miss_num_map(p2_a6);
    ddp_cust_profile_amt_rec.max_interest_charge := rosetta_g_miss_num_map(p2_a7);
    ddp_cust_profile_amt_rec.min_statement_amount := rosetta_g_miss_num_map(p2_a8);
    ddp_cust_profile_amt_rec.auto_rec_min_receipt_amount := rosetta_g_miss_num_map(p2_a9);
    ddp_cust_profile_amt_rec.interest_rate := rosetta_g_miss_num_map(p2_a10);
    ddp_cust_profile_amt_rec.attribute_category := p2_a11;
    ddp_cust_profile_amt_rec.attribute1 := p2_a12;
    ddp_cust_profile_amt_rec.attribute2 := p2_a13;
    ddp_cust_profile_amt_rec.attribute3 := p2_a14;
    ddp_cust_profile_amt_rec.attribute4 := p2_a15;
    ddp_cust_profile_amt_rec.attribute5 := p2_a16;
    ddp_cust_profile_amt_rec.attribute6 := p2_a17;
    ddp_cust_profile_amt_rec.attribute7 := p2_a18;
    ddp_cust_profile_amt_rec.attribute8 := p2_a19;
    ddp_cust_profile_amt_rec.attribute9 := p2_a20;
    ddp_cust_profile_amt_rec.attribute10 := p2_a21;
    ddp_cust_profile_amt_rec.attribute11 := p2_a22;
    ddp_cust_profile_amt_rec.attribute12 := p2_a23;
    ddp_cust_profile_amt_rec.attribute13 := p2_a24;
    ddp_cust_profile_amt_rec.attribute14 := p2_a25;
    ddp_cust_profile_amt_rec.attribute15 := p2_a26;
    ddp_cust_profile_amt_rec.min_fc_balance_amount := rosetta_g_miss_num_map(p2_a27);
    ddp_cust_profile_amt_rec.min_fc_invoice_amount := rosetta_g_miss_num_map(p2_a28);
    ddp_cust_profile_amt_rec.cust_account_id := rosetta_g_miss_num_map(p2_a29);
    ddp_cust_profile_amt_rec.site_use_id := rosetta_g_miss_num_map(p2_a30);
    ddp_cust_profile_amt_rec.expiration_date := rosetta_g_miss_date_in_map(p2_a31);
    ddp_cust_profile_amt_rec.jgzz_attribute_category := p2_a32;
    ddp_cust_profile_amt_rec.jgzz_attribute1 := p2_a33;
    ddp_cust_profile_amt_rec.jgzz_attribute2 := p2_a34;
    ddp_cust_profile_amt_rec.jgzz_attribute3 := p2_a35;
    ddp_cust_profile_amt_rec.jgzz_attribute4 := p2_a36;
    ddp_cust_profile_amt_rec.jgzz_attribute5 := p2_a37;
    ddp_cust_profile_amt_rec.jgzz_attribute6 := p2_a38;
    ddp_cust_profile_amt_rec.jgzz_attribute7 := p2_a39;
    ddp_cust_profile_amt_rec.jgzz_attribute8 := p2_a40;
    ddp_cust_profile_amt_rec.jgzz_attribute9 := p2_a41;
    ddp_cust_profile_amt_rec.jgzz_attribute10 := p2_a42;
    ddp_cust_profile_amt_rec.jgzz_attribute11 := p2_a43;
    ddp_cust_profile_amt_rec.jgzz_attribute12 := p2_a44;
    ddp_cust_profile_amt_rec.jgzz_attribute13 := p2_a45;
    ddp_cust_profile_amt_rec.jgzz_attribute14 := p2_a46;
    ddp_cust_profile_amt_rec.jgzz_attribute15 := p2_a47;
    ddp_cust_profile_amt_rec.global_attribute1 := p2_a48;
    ddp_cust_profile_amt_rec.global_attribute2 := p2_a49;
    ddp_cust_profile_amt_rec.global_attribute3 := p2_a50;
    ddp_cust_profile_amt_rec.global_attribute4 := p2_a51;
    ddp_cust_profile_amt_rec.global_attribute5 := p2_a52;
    ddp_cust_profile_amt_rec.global_attribute6 := p2_a53;
    ddp_cust_profile_amt_rec.global_attribute7 := p2_a54;
    ddp_cust_profile_amt_rec.global_attribute8 := p2_a55;
    ddp_cust_profile_amt_rec.global_attribute9 := p2_a56;
    ddp_cust_profile_amt_rec.global_attribute10 := p2_a57;
    ddp_cust_profile_amt_rec.global_attribute11 := p2_a58;
    ddp_cust_profile_amt_rec.global_attribute12 := p2_a59;
    ddp_cust_profile_amt_rec.global_attribute13 := p2_a60;
    ddp_cust_profile_amt_rec.global_attribute14 := p2_a61;
    ddp_cust_profile_amt_rec.global_attribute15 := p2_a62;
    ddp_cust_profile_amt_rec.global_attribute16 := p2_a63;
    ddp_cust_profile_amt_rec.global_attribute17 := p2_a64;
    ddp_cust_profile_amt_rec.global_attribute18 := p2_a65;
    ddp_cust_profile_amt_rec.global_attribute19 := p2_a66;
    ddp_cust_profile_amt_rec.global_attribute20 := p2_a67;
    ddp_cust_profile_amt_rec.global_attribute_category := p2_a68;
    ddp_cust_profile_amt_rec.created_by_module := p2_a69;
    ddp_cust_profile_amt_rec.application_id := rosetta_g_miss_num_map(p2_a70);
    ddp_cust_profile_amt_rec.exchange_rate_type := p2_a71;
    ddp_cust_profile_amt_rec.min_fc_invoice_overdue_type := p2_a72;
    ddp_cust_profile_amt_rec.min_fc_invoice_percent := rosetta_g_miss_num_map(p2_a73);
    ddp_cust_profile_amt_rec.min_fc_balance_overdue_type := p2_a74;
    ddp_cust_profile_amt_rec.min_fc_balance_percent := rosetta_g_miss_num_map(p2_a75);
    ddp_cust_profile_amt_rec.interest_type := p2_a76;
    ddp_cust_profile_amt_rec.interest_fixed_amount := rosetta_g_miss_num_map(p2_a77);
    ddp_cust_profile_amt_rec.interest_schedule_id := rosetta_g_miss_num_map(p2_a78);
    ddp_cust_profile_amt_rec.penalty_type := p2_a79;
    ddp_cust_profile_amt_rec.penalty_rate := rosetta_g_miss_num_map(p2_a80);
    ddp_cust_profile_amt_rec.min_interest_charge := rosetta_g_miss_num_map(p2_a81);
    ddp_cust_profile_amt_rec.penalty_fixed_amount := rosetta_g_miss_num_map(p2_a82);
    ddp_cust_profile_amt_rec.penalty_schedule_id := rosetta_g_miss_num_map(p2_a83);





    -- here's the delegated call to the old PL/SQL routine
    hz_customer_profile_v2pub.create_cust_profile_amt(p_init_msg_list,
      p_check_foreign_key,
      ddp_cust_profile_amt_rec,
      x_cust_acct_profile_amt_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure update_cust_profile_amt_7(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  NUMBER := null
    , p1_a4  NUMBER := null
    , p1_a5  NUMBER := null
    , p1_a6  NUMBER := null
    , p1_a7  NUMBER := null
    , p1_a8  NUMBER := null
    , p1_a9  NUMBER := null
    , p1_a10  NUMBER := null
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
    , p1_a27  NUMBER := null
    , p1_a28  NUMBER := null
    , p1_a29  NUMBER := null
    , p1_a30  NUMBER := null
    , p1_a31  DATE := null
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
    , p1_a49  VARCHAR2 := null
    , p1_a50  VARCHAR2 := null
    , p1_a51  VARCHAR2 := null
    , p1_a52  VARCHAR2 := null
    , p1_a53  VARCHAR2 := null
    , p1_a54  VARCHAR2 := null
    , p1_a55  VARCHAR2 := null
    , p1_a56  VARCHAR2 := null
    , p1_a57  VARCHAR2 := null
    , p1_a58  VARCHAR2 := null
    , p1_a59  VARCHAR2 := null
    , p1_a60  VARCHAR2 := null
    , p1_a61  VARCHAR2 := null
    , p1_a62  VARCHAR2 := null
    , p1_a63  VARCHAR2 := null
    , p1_a64  VARCHAR2 := null
    , p1_a65  VARCHAR2 := null
    , p1_a66  VARCHAR2 := null
    , p1_a67  VARCHAR2 := null
    , p1_a68  VARCHAR2 := null
    , p1_a69  VARCHAR2 := null
    , p1_a70  NUMBER := null
    , p1_a71  VARCHAR2 := null
    , p1_a72  VARCHAR2 := null
    , p1_a73  NUMBER := null
    , p1_a74  VARCHAR2 := null
    , p1_a75  NUMBER := null
    , p1_a76  VARCHAR2 := null
    , p1_a77  NUMBER := null
    , p1_a78  NUMBER := null
    , p1_a79  VARCHAR2 := null
    , p1_a80  NUMBER := null
    , p1_a81  NUMBER := null
    , p1_a82  NUMBER := null
    , p1_a83  NUMBER := null
  )
  as
    ddp_cust_profile_amt_rec hz_customer_profile_v2pub.cust_profile_amt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cust_profile_amt_rec.cust_acct_profile_amt_id := rosetta_g_miss_num_map(p1_a0);
    ddp_cust_profile_amt_rec.cust_account_profile_id := rosetta_g_miss_num_map(p1_a1);
    ddp_cust_profile_amt_rec.currency_code := p1_a2;
    ddp_cust_profile_amt_rec.trx_credit_limit := rosetta_g_miss_num_map(p1_a3);
    ddp_cust_profile_amt_rec.overall_credit_limit := rosetta_g_miss_num_map(p1_a4);
    ddp_cust_profile_amt_rec.min_dunning_amount := rosetta_g_miss_num_map(p1_a5);
    ddp_cust_profile_amt_rec.min_dunning_invoice_amount := rosetta_g_miss_num_map(p1_a6);
    ddp_cust_profile_amt_rec.max_interest_charge := rosetta_g_miss_num_map(p1_a7);
    ddp_cust_profile_amt_rec.min_statement_amount := rosetta_g_miss_num_map(p1_a8);
    ddp_cust_profile_amt_rec.auto_rec_min_receipt_amount := rosetta_g_miss_num_map(p1_a9);
    ddp_cust_profile_amt_rec.interest_rate := rosetta_g_miss_num_map(p1_a10);
    ddp_cust_profile_amt_rec.attribute_category := p1_a11;
    ddp_cust_profile_amt_rec.attribute1 := p1_a12;
    ddp_cust_profile_amt_rec.attribute2 := p1_a13;
    ddp_cust_profile_amt_rec.attribute3 := p1_a14;
    ddp_cust_profile_amt_rec.attribute4 := p1_a15;
    ddp_cust_profile_amt_rec.attribute5 := p1_a16;
    ddp_cust_profile_amt_rec.attribute6 := p1_a17;
    ddp_cust_profile_amt_rec.attribute7 := p1_a18;
    ddp_cust_profile_amt_rec.attribute8 := p1_a19;
    ddp_cust_profile_amt_rec.attribute9 := p1_a20;
    ddp_cust_profile_amt_rec.attribute10 := p1_a21;
    ddp_cust_profile_amt_rec.attribute11 := p1_a22;
    ddp_cust_profile_amt_rec.attribute12 := p1_a23;
    ddp_cust_profile_amt_rec.attribute13 := p1_a24;
    ddp_cust_profile_amt_rec.attribute14 := p1_a25;
    ddp_cust_profile_amt_rec.attribute15 := p1_a26;
    ddp_cust_profile_amt_rec.min_fc_balance_amount := rosetta_g_miss_num_map(p1_a27);
    ddp_cust_profile_amt_rec.min_fc_invoice_amount := rosetta_g_miss_num_map(p1_a28);
    ddp_cust_profile_amt_rec.cust_account_id := rosetta_g_miss_num_map(p1_a29);
    ddp_cust_profile_amt_rec.site_use_id := rosetta_g_miss_num_map(p1_a30);
    ddp_cust_profile_amt_rec.expiration_date := rosetta_g_miss_date_in_map(p1_a31);
    ddp_cust_profile_amt_rec.jgzz_attribute_category := p1_a32;
    ddp_cust_profile_amt_rec.jgzz_attribute1 := p1_a33;
    ddp_cust_profile_amt_rec.jgzz_attribute2 := p1_a34;
    ddp_cust_profile_amt_rec.jgzz_attribute3 := p1_a35;
    ddp_cust_profile_amt_rec.jgzz_attribute4 := p1_a36;
    ddp_cust_profile_amt_rec.jgzz_attribute5 := p1_a37;
    ddp_cust_profile_amt_rec.jgzz_attribute6 := p1_a38;
    ddp_cust_profile_amt_rec.jgzz_attribute7 := p1_a39;
    ddp_cust_profile_amt_rec.jgzz_attribute8 := p1_a40;
    ddp_cust_profile_amt_rec.jgzz_attribute9 := p1_a41;
    ddp_cust_profile_amt_rec.jgzz_attribute10 := p1_a42;
    ddp_cust_profile_amt_rec.jgzz_attribute11 := p1_a43;
    ddp_cust_profile_amt_rec.jgzz_attribute12 := p1_a44;
    ddp_cust_profile_amt_rec.jgzz_attribute13 := p1_a45;
    ddp_cust_profile_amt_rec.jgzz_attribute14 := p1_a46;
    ddp_cust_profile_amt_rec.jgzz_attribute15 := p1_a47;
    ddp_cust_profile_amt_rec.global_attribute1 := p1_a48;
    ddp_cust_profile_amt_rec.global_attribute2 := p1_a49;
    ddp_cust_profile_amt_rec.global_attribute3 := p1_a50;
    ddp_cust_profile_amt_rec.global_attribute4 := p1_a51;
    ddp_cust_profile_amt_rec.global_attribute5 := p1_a52;
    ddp_cust_profile_amt_rec.global_attribute6 := p1_a53;
    ddp_cust_profile_amt_rec.global_attribute7 := p1_a54;
    ddp_cust_profile_amt_rec.global_attribute8 := p1_a55;
    ddp_cust_profile_amt_rec.global_attribute9 := p1_a56;
    ddp_cust_profile_amt_rec.global_attribute10 := p1_a57;
    ddp_cust_profile_amt_rec.global_attribute11 := p1_a58;
    ddp_cust_profile_amt_rec.global_attribute12 := p1_a59;
    ddp_cust_profile_amt_rec.global_attribute13 := p1_a60;
    ddp_cust_profile_amt_rec.global_attribute14 := p1_a61;
    ddp_cust_profile_amt_rec.global_attribute15 := p1_a62;
    ddp_cust_profile_amt_rec.global_attribute16 := p1_a63;
    ddp_cust_profile_amt_rec.global_attribute17 := p1_a64;
    ddp_cust_profile_amt_rec.global_attribute18 := p1_a65;
    ddp_cust_profile_amt_rec.global_attribute19 := p1_a66;
    ddp_cust_profile_amt_rec.global_attribute20 := p1_a67;
    ddp_cust_profile_amt_rec.global_attribute_category := p1_a68;
    ddp_cust_profile_amt_rec.created_by_module := p1_a69;
    ddp_cust_profile_amt_rec.application_id := rosetta_g_miss_num_map(p1_a70);
    ddp_cust_profile_amt_rec.exchange_rate_type := p1_a71;
    ddp_cust_profile_amt_rec.min_fc_invoice_overdue_type := p1_a72;
    ddp_cust_profile_amt_rec.min_fc_invoice_percent := rosetta_g_miss_num_map(p1_a73);
    ddp_cust_profile_amt_rec.min_fc_balance_overdue_type := p1_a74;
    ddp_cust_profile_amt_rec.min_fc_balance_percent := rosetta_g_miss_num_map(p1_a75);
    ddp_cust_profile_amt_rec.interest_type := p1_a76;
    ddp_cust_profile_amt_rec.interest_fixed_amount := rosetta_g_miss_num_map(p1_a77);
    ddp_cust_profile_amt_rec.interest_schedule_id := rosetta_g_miss_num_map(p1_a78);
    ddp_cust_profile_amt_rec.penalty_type := p1_a79;
    ddp_cust_profile_amt_rec.penalty_rate := rosetta_g_miss_num_map(p1_a80);
    ddp_cust_profile_amt_rec.min_interest_charge := rosetta_g_miss_num_map(p1_a81);
    ddp_cust_profile_amt_rec.penalty_fixed_amount := rosetta_g_miss_num_map(p1_a82);
    ddp_cust_profile_amt_rec.penalty_schedule_id := rosetta_g_miss_num_map(p1_a83);





    -- here's the delegated call to the old PL/SQL routine
    hz_customer_profile_v2pub.update_cust_profile_amt(p_init_msg_list,
      ddp_cust_profile_amt_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_cust_profile_amt_rec_8(p_init_msg_list  VARCHAR2
    , p_cust_acct_profile_amt_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  NUMBER
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  NUMBER
    , p2_a6 out nocopy  NUMBER
    , p2_a7 out nocopy  NUMBER
    , p2_a8 out nocopy  NUMBER
    , p2_a9 out nocopy  NUMBER
    , p2_a10 out nocopy  NUMBER
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
    , p2_a27 out nocopy  NUMBER
    , p2_a28 out nocopy  NUMBER
    , p2_a29 out nocopy  NUMBER
    , p2_a30 out nocopy  NUMBER
    , p2_a31 out nocopy  DATE
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
    , p2_a49 out nocopy  VARCHAR2
    , p2_a50 out nocopy  VARCHAR2
    , p2_a51 out nocopy  VARCHAR2
    , p2_a52 out nocopy  VARCHAR2
    , p2_a53 out nocopy  VARCHAR2
    , p2_a54 out nocopy  VARCHAR2
    , p2_a55 out nocopy  VARCHAR2
    , p2_a56 out nocopy  VARCHAR2
    , p2_a57 out nocopy  VARCHAR2
    , p2_a58 out nocopy  VARCHAR2
    , p2_a59 out nocopy  VARCHAR2
    , p2_a60 out nocopy  VARCHAR2
    , p2_a61 out nocopy  VARCHAR2
    , p2_a62 out nocopy  VARCHAR2
    , p2_a63 out nocopy  VARCHAR2
    , p2_a64 out nocopy  VARCHAR2
    , p2_a65 out nocopy  VARCHAR2
    , p2_a66 out nocopy  VARCHAR2
    , p2_a67 out nocopy  VARCHAR2
    , p2_a68 out nocopy  VARCHAR2
    , p2_a69 out nocopy  VARCHAR2
    , p2_a70 out nocopy  NUMBER
    , p2_a71 out nocopy  VARCHAR2
    , p2_a72 out nocopy  VARCHAR2
    , p2_a73 out nocopy  NUMBER
    , p2_a74 out nocopy  VARCHAR2
    , p2_a75 out nocopy  NUMBER
    , p2_a76 out nocopy  VARCHAR2
    , p2_a77 out nocopy  NUMBER
    , p2_a78 out nocopy  NUMBER
    , p2_a79 out nocopy  VARCHAR2
    , p2_a80 out nocopy  NUMBER
    , p2_a81 out nocopy  NUMBER
    , p2_a82 out nocopy  NUMBER
    , p2_a83 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_cust_profile_amt_rec hz_customer_profile_v2pub.cust_profile_amt_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_customer_profile_v2pub.get_cust_profile_amt_rec(p_init_msg_list,
      p_cust_acct_profile_amt_id,
      ddx_cust_profile_amt_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.cust_acct_profile_amt_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.cust_account_profile_id);
    p2_a2 := ddx_cust_profile_amt_rec.currency_code;
    p2_a3 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.trx_credit_limit);
    p2_a4 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.overall_credit_limit);
    p2_a5 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_dunning_amount);
    p2_a6 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_dunning_invoice_amount);
    p2_a7 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.max_interest_charge);
    p2_a8 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_statement_amount);
    p2_a9 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.auto_rec_min_receipt_amount);
    p2_a10 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.interest_rate);
    p2_a11 := ddx_cust_profile_amt_rec.attribute_category;
    p2_a12 := ddx_cust_profile_amt_rec.attribute1;
    p2_a13 := ddx_cust_profile_amt_rec.attribute2;
    p2_a14 := ddx_cust_profile_amt_rec.attribute3;
    p2_a15 := ddx_cust_profile_amt_rec.attribute4;
    p2_a16 := ddx_cust_profile_amt_rec.attribute5;
    p2_a17 := ddx_cust_profile_amt_rec.attribute6;
    p2_a18 := ddx_cust_profile_amt_rec.attribute7;
    p2_a19 := ddx_cust_profile_amt_rec.attribute8;
    p2_a20 := ddx_cust_profile_amt_rec.attribute9;
    p2_a21 := ddx_cust_profile_amt_rec.attribute10;
    p2_a22 := ddx_cust_profile_amt_rec.attribute11;
    p2_a23 := ddx_cust_profile_amt_rec.attribute12;
    p2_a24 := ddx_cust_profile_amt_rec.attribute13;
    p2_a25 := ddx_cust_profile_amt_rec.attribute14;
    p2_a26 := ddx_cust_profile_amt_rec.attribute15;
    p2_a27 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_fc_balance_amount);
    p2_a28 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_fc_invoice_amount);
    p2_a29 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.cust_account_id);
    p2_a30 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.site_use_id);
    p2_a31 := ddx_cust_profile_amt_rec.expiration_date;
    p2_a32 := ddx_cust_profile_amt_rec.jgzz_attribute_category;
    p2_a33 := ddx_cust_profile_amt_rec.jgzz_attribute1;
    p2_a34 := ddx_cust_profile_amt_rec.jgzz_attribute2;
    p2_a35 := ddx_cust_profile_amt_rec.jgzz_attribute3;
    p2_a36 := ddx_cust_profile_amt_rec.jgzz_attribute4;
    p2_a37 := ddx_cust_profile_amt_rec.jgzz_attribute5;
    p2_a38 := ddx_cust_profile_amt_rec.jgzz_attribute6;
    p2_a39 := ddx_cust_profile_amt_rec.jgzz_attribute7;
    p2_a40 := ddx_cust_profile_amt_rec.jgzz_attribute8;
    p2_a41 := ddx_cust_profile_amt_rec.jgzz_attribute9;
    p2_a42 := ddx_cust_profile_amt_rec.jgzz_attribute10;
    p2_a43 := ddx_cust_profile_amt_rec.jgzz_attribute11;
    p2_a44 := ddx_cust_profile_amt_rec.jgzz_attribute12;
    p2_a45 := ddx_cust_profile_amt_rec.jgzz_attribute13;
    p2_a46 := ddx_cust_profile_amt_rec.jgzz_attribute14;
    p2_a47 := ddx_cust_profile_amt_rec.jgzz_attribute15;
    p2_a48 := ddx_cust_profile_amt_rec.global_attribute1;
    p2_a49 := ddx_cust_profile_amt_rec.global_attribute2;
    p2_a50 := ddx_cust_profile_amt_rec.global_attribute3;
    p2_a51 := ddx_cust_profile_amt_rec.global_attribute4;
    p2_a52 := ddx_cust_profile_amt_rec.global_attribute5;
    p2_a53 := ddx_cust_profile_amt_rec.global_attribute6;
    p2_a54 := ddx_cust_profile_amt_rec.global_attribute7;
    p2_a55 := ddx_cust_profile_amt_rec.global_attribute8;
    p2_a56 := ddx_cust_profile_amt_rec.global_attribute9;
    p2_a57 := ddx_cust_profile_amt_rec.global_attribute10;
    p2_a58 := ddx_cust_profile_amt_rec.global_attribute11;
    p2_a59 := ddx_cust_profile_amt_rec.global_attribute12;
    p2_a60 := ddx_cust_profile_amt_rec.global_attribute13;
    p2_a61 := ddx_cust_profile_amt_rec.global_attribute14;
    p2_a62 := ddx_cust_profile_amt_rec.global_attribute15;
    p2_a63 := ddx_cust_profile_amt_rec.global_attribute16;
    p2_a64 := ddx_cust_profile_amt_rec.global_attribute17;
    p2_a65 := ddx_cust_profile_amt_rec.global_attribute18;
    p2_a66 := ddx_cust_profile_amt_rec.global_attribute19;
    p2_a67 := ddx_cust_profile_amt_rec.global_attribute20;
    p2_a68 := ddx_cust_profile_amt_rec.global_attribute_category;
    p2_a69 := ddx_cust_profile_amt_rec.created_by_module;
    p2_a70 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.application_id);
    p2_a71 := ddx_cust_profile_amt_rec.exchange_rate_type;
    p2_a72 := ddx_cust_profile_amt_rec.min_fc_invoice_overdue_type;
    p2_a73 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_fc_invoice_percent);
    p2_a74 := ddx_cust_profile_amt_rec.min_fc_balance_overdue_type;
    p2_a75 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_fc_balance_percent);
    p2_a76 := ddx_cust_profile_amt_rec.interest_type;
    p2_a77 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.interest_fixed_amount);
    p2_a78 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.interest_schedule_id);
    p2_a79 := ddx_cust_profile_amt_rec.penalty_type;
    p2_a80 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.penalty_rate);
    p2_a81 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.min_interest_charge);
    p2_a82 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.penalty_fixed_amount);
    p2_a83 := rosetta_g_miss_num_map(ddx_cust_profile_amt_rec.penalty_schedule_id);



  end;

end hz_customer_profile_v2pub_jw;

/
