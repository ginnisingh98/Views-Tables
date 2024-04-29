--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLE_PUB_W" as
  /* $Header: amswpdlb.pls 120.0 2005/05/31 15:52:12 appldev noship $ */
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

  procedure create_deliverable(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_deliv_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  NUMBER := 0-1962.0724
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  NUMBER := 0-1962.0724
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
    , p7_a75  NUMBER := 0-1962.0724
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  NUMBER := 0-1962.0724
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_deliv_rec ams_deliverable_pub.deliv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_deliv_rec.deliverable_id := rosetta_g_miss_num_map(p7_a0);
    ddp_deliv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_deliv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_deliv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_deliv_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_deliv_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_deliv_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_deliv_rec.language_code := p7_a7;
    ddp_deliv_rec.version := p7_a8;
    ddp_deliv_rec.application_id := rosetta_g_miss_num_map(p7_a9);
    ddp_deliv_rec.user_status_id := rosetta_g_miss_num_map(p7_a10);
    ddp_deliv_rec.status_code := p7_a11;
    ddp_deliv_rec.status_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_deliv_rec.active_flag := p7_a13;
    ddp_deliv_rec.private_flag := p7_a14;
    ddp_deliv_rec.owner_user_id := rosetta_g_miss_num_map(p7_a15);
    ddp_deliv_rec.fund_source_id := rosetta_g_miss_num_map(p7_a16);
    ddp_deliv_rec.fund_source_type := p7_a17;
    ddp_deliv_rec.category_type_id := rosetta_g_miss_num_map(p7_a18);
    ddp_deliv_rec.category_sub_type_id := rosetta_g_miss_num_map(p7_a19);
    ddp_deliv_rec.kit_flag := p7_a20;
    ddp_deliv_rec.inventory_flag := p7_a21;
    ddp_deliv_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a22);
    ddp_deliv_rec.inventory_item_org_id := rosetta_g_miss_num_map(p7_a23);
    ddp_deliv_rec.pricelist_header_id := rosetta_g_miss_num_map(p7_a24);
    ddp_deliv_rec.pricelist_line_id := rosetta_g_miss_num_map(p7_a25);
    ddp_deliv_rec.actual_avail_from_date := rosetta_g_miss_date_in_map(p7_a26);
    ddp_deliv_rec.actual_avail_to_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_deliv_rec.forecasted_complete_date := rosetta_g_miss_date_in_map(p7_a28);
    ddp_deliv_rec.actual_complete_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_deliv_rec.transaction_currency_code := p7_a30;
    ddp_deliv_rec.functional_currency_code := p7_a31;
    ddp_deliv_rec.budget_amount_tc := rosetta_g_miss_num_map(p7_a32);
    ddp_deliv_rec.budget_amount_fc := rosetta_g_miss_num_map(p7_a33);
    ddp_deliv_rec.replaced_by_deliverable_id := rosetta_g_miss_num_map(p7_a34);
    ddp_deliv_rec.can_fulfill_electronic_flag := p7_a35;
    ddp_deliv_rec.can_fulfill_physical_flag := p7_a36;
    ddp_deliv_rec.jtf_amv_item_id := rosetta_g_miss_num_map(p7_a37);
    ddp_deliv_rec.non_inv_ctrl_code := p7_a38;
    ddp_deliv_rec.non_inv_quantity_on_hand := rosetta_g_miss_num_map(p7_a39);
    ddp_deliv_rec.non_inv_quantity_on_order := rosetta_g_miss_num_map(p7_a40);
    ddp_deliv_rec.non_inv_quantity_on_reserve := rosetta_g_miss_num_map(p7_a41);
    ddp_deliv_rec.chargeback_amount := rosetta_g_miss_num_map(p7_a42);
    ddp_deliv_rec.chargeback_uom := p7_a43;
    ddp_deliv_rec.chargeback_amount_curr_code := p7_a44;
    ddp_deliv_rec.deliverable_code := p7_a45;
    ddp_deliv_rec.deliverable_pick_flag := p7_a46;
    ddp_deliv_rec.currency_code := p7_a47;
    ddp_deliv_rec.forecasted_cost := rosetta_g_miss_num_map(p7_a48);
    ddp_deliv_rec.actual_cost := rosetta_g_miss_num_map(p7_a49);
    ddp_deliv_rec.forecasted_responses := rosetta_g_miss_num_map(p7_a50);
    ddp_deliv_rec.actual_responses := rosetta_g_miss_num_map(p7_a51);
    ddp_deliv_rec.country := p7_a52;
    ddp_deliv_rec.default_approver_id := rosetta_g_miss_num_map(p7_a53);
    ddp_deliv_rec.attribute_category := p7_a54;
    ddp_deliv_rec.attribute1 := p7_a55;
    ddp_deliv_rec.attribute2 := p7_a56;
    ddp_deliv_rec.attribute3 := p7_a57;
    ddp_deliv_rec.attribute4 := p7_a58;
    ddp_deliv_rec.attribute5 := p7_a59;
    ddp_deliv_rec.attribute6 := p7_a60;
    ddp_deliv_rec.attribute7 := p7_a61;
    ddp_deliv_rec.attribute8 := p7_a62;
    ddp_deliv_rec.attribute9 := p7_a63;
    ddp_deliv_rec.attribute10 := p7_a64;
    ddp_deliv_rec.attribute11 := p7_a65;
    ddp_deliv_rec.attribute12 := p7_a66;
    ddp_deliv_rec.attribute13 := p7_a67;
    ddp_deliv_rec.attribute14 := p7_a68;
    ddp_deliv_rec.attribute15 := p7_a69;
    ddp_deliv_rec.deliverable_name := p7_a70;
    ddp_deliv_rec.description := p7_a71;
    ddp_deliv_rec.start_period_name := p7_a72;
    ddp_deliv_rec.end_period_name := p7_a73;
    ddp_deliv_rec.deliverable_calendar := p7_a74;
    ddp_deliv_rec.country_id := rosetta_g_miss_num_map(p7_a75);
    ddp_deliv_rec.setup_id := rosetta_g_miss_num_map(p7_a76);
    ddp_deliv_rec.item_number := p7_a77;
    ddp_deliv_rec.associate_flag := p7_a78;
    ddp_deliv_rec.master_object_id := rosetta_g_miss_num_map(p7_a79);
    ddp_deliv_rec.master_object_type := p7_a80;
    ddp_deliv_rec.email_content_type := p7_a81;


    -- here's the delegated call to the old PL/SQL routine
    ams_deliverable_pub.create_deliverable(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deliv_rec,
      x_deliv_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_deliverable(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  DATE := fnd_api.g_miss_date
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  NUMBER := 0-1962.0724
    , p7_a49  NUMBER := 0-1962.0724
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  NUMBER := 0-1962.0724
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
    , p7_a75  NUMBER := 0-1962.0724
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  NUMBER := 0-1962.0724
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_deliv_rec ams_deliverable_pub.deliv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_deliv_rec.deliverable_id := rosetta_g_miss_num_map(p7_a0);
    ddp_deliv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_deliv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_deliv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_deliv_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_deliv_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_deliv_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_deliv_rec.language_code := p7_a7;
    ddp_deliv_rec.version := p7_a8;
    ddp_deliv_rec.application_id := rosetta_g_miss_num_map(p7_a9);
    ddp_deliv_rec.user_status_id := rosetta_g_miss_num_map(p7_a10);
    ddp_deliv_rec.status_code := p7_a11;
    ddp_deliv_rec.status_date := rosetta_g_miss_date_in_map(p7_a12);
    ddp_deliv_rec.active_flag := p7_a13;
    ddp_deliv_rec.private_flag := p7_a14;
    ddp_deliv_rec.owner_user_id := rosetta_g_miss_num_map(p7_a15);
    ddp_deliv_rec.fund_source_id := rosetta_g_miss_num_map(p7_a16);
    ddp_deliv_rec.fund_source_type := p7_a17;
    ddp_deliv_rec.category_type_id := rosetta_g_miss_num_map(p7_a18);
    ddp_deliv_rec.category_sub_type_id := rosetta_g_miss_num_map(p7_a19);
    ddp_deliv_rec.kit_flag := p7_a20;
    ddp_deliv_rec.inventory_flag := p7_a21;
    ddp_deliv_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a22);
    ddp_deliv_rec.inventory_item_org_id := rosetta_g_miss_num_map(p7_a23);
    ddp_deliv_rec.pricelist_header_id := rosetta_g_miss_num_map(p7_a24);
    ddp_deliv_rec.pricelist_line_id := rosetta_g_miss_num_map(p7_a25);
    ddp_deliv_rec.actual_avail_from_date := rosetta_g_miss_date_in_map(p7_a26);
    ddp_deliv_rec.actual_avail_to_date := rosetta_g_miss_date_in_map(p7_a27);
    ddp_deliv_rec.forecasted_complete_date := rosetta_g_miss_date_in_map(p7_a28);
    ddp_deliv_rec.actual_complete_date := rosetta_g_miss_date_in_map(p7_a29);
    ddp_deliv_rec.transaction_currency_code := p7_a30;
    ddp_deliv_rec.functional_currency_code := p7_a31;
    ddp_deliv_rec.budget_amount_tc := rosetta_g_miss_num_map(p7_a32);
    ddp_deliv_rec.budget_amount_fc := rosetta_g_miss_num_map(p7_a33);
    ddp_deliv_rec.replaced_by_deliverable_id := rosetta_g_miss_num_map(p7_a34);
    ddp_deliv_rec.can_fulfill_electronic_flag := p7_a35;
    ddp_deliv_rec.can_fulfill_physical_flag := p7_a36;
    ddp_deliv_rec.jtf_amv_item_id := rosetta_g_miss_num_map(p7_a37);
    ddp_deliv_rec.non_inv_ctrl_code := p7_a38;
    ddp_deliv_rec.non_inv_quantity_on_hand := rosetta_g_miss_num_map(p7_a39);
    ddp_deliv_rec.non_inv_quantity_on_order := rosetta_g_miss_num_map(p7_a40);
    ddp_deliv_rec.non_inv_quantity_on_reserve := rosetta_g_miss_num_map(p7_a41);
    ddp_deliv_rec.chargeback_amount := rosetta_g_miss_num_map(p7_a42);
    ddp_deliv_rec.chargeback_uom := p7_a43;
    ddp_deliv_rec.chargeback_amount_curr_code := p7_a44;
    ddp_deliv_rec.deliverable_code := p7_a45;
    ddp_deliv_rec.deliverable_pick_flag := p7_a46;
    ddp_deliv_rec.currency_code := p7_a47;
    ddp_deliv_rec.forecasted_cost := rosetta_g_miss_num_map(p7_a48);
    ddp_deliv_rec.actual_cost := rosetta_g_miss_num_map(p7_a49);
    ddp_deliv_rec.forecasted_responses := rosetta_g_miss_num_map(p7_a50);
    ddp_deliv_rec.actual_responses := rosetta_g_miss_num_map(p7_a51);
    ddp_deliv_rec.country := p7_a52;
    ddp_deliv_rec.default_approver_id := rosetta_g_miss_num_map(p7_a53);
    ddp_deliv_rec.attribute_category := p7_a54;
    ddp_deliv_rec.attribute1 := p7_a55;
    ddp_deliv_rec.attribute2 := p7_a56;
    ddp_deliv_rec.attribute3 := p7_a57;
    ddp_deliv_rec.attribute4 := p7_a58;
    ddp_deliv_rec.attribute5 := p7_a59;
    ddp_deliv_rec.attribute6 := p7_a60;
    ddp_deliv_rec.attribute7 := p7_a61;
    ddp_deliv_rec.attribute8 := p7_a62;
    ddp_deliv_rec.attribute9 := p7_a63;
    ddp_deliv_rec.attribute10 := p7_a64;
    ddp_deliv_rec.attribute11 := p7_a65;
    ddp_deliv_rec.attribute12 := p7_a66;
    ddp_deliv_rec.attribute13 := p7_a67;
    ddp_deliv_rec.attribute14 := p7_a68;
    ddp_deliv_rec.attribute15 := p7_a69;
    ddp_deliv_rec.deliverable_name := p7_a70;
    ddp_deliv_rec.description := p7_a71;
    ddp_deliv_rec.start_period_name := p7_a72;
    ddp_deliv_rec.end_period_name := p7_a73;
    ddp_deliv_rec.deliverable_calendar := p7_a74;
    ddp_deliv_rec.country_id := rosetta_g_miss_num_map(p7_a75);
    ddp_deliv_rec.setup_id := rosetta_g_miss_num_map(p7_a76);
    ddp_deliv_rec.item_number := p7_a77;
    ddp_deliv_rec.associate_flag := p7_a78;
    ddp_deliv_rec.master_object_id := rosetta_g_miss_num_map(p7_a79);
    ddp_deliv_rec.master_object_type := p7_a80;
    ddp_deliv_rec.email_content_type := p7_a81;

    -- here's the delegated call to the old PL/SQL routine
    ams_deliverable_pub.update_deliverable(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deliv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end ams_deliverable_pub_w;

/
