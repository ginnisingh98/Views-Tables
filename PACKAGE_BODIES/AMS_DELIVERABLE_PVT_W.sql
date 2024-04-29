--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLE_PVT_W" as
  /* $Header: amswdelb.pls 120.0 2005/05/31 22:47:02 appldev noship $ */
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

  procedure create_deliverable(p_api_version  NUMBER
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
    ddp_deliv_rec ams_deliverable_pvt.deliv_rec_type;
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
    ams_deliverable_pvt.create_deliverable(p_api_version,
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

  procedure update_deliverable(p_api_version  NUMBER
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
    ddp_deliv_rec ams_deliverable_pvt.deliv_rec_type;
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
    ams_deliverable_pvt.update_deliverable(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deliv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
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
    ddp_deliv_rec ams_deliverable_pvt.deliv_rec_type;
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
    ams_deliverable_pvt.validate_deliverable(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_deliv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_deliv_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  DATE := fnd_api.g_miss_date
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  NUMBER := 0-1962.0724
    , p0_a49  NUMBER := 0-1962.0724
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  NUMBER := 0-1962.0724
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  NUMBER := 0-1962.0724
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  NUMBER := 0-1962.0724
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_deliv_rec ams_deliverable_pvt.deliv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_deliv_rec.deliverable_id := rosetta_g_miss_num_map(p0_a0);
    ddp_deliv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_deliv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_deliv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_deliv_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_deliv_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_deliv_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_deliv_rec.language_code := p0_a7;
    ddp_deliv_rec.version := p0_a8;
    ddp_deliv_rec.application_id := rosetta_g_miss_num_map(p0_a9);
    ddp_deliv_rec.user_status_id := rosetta_g_miss_num_map(p0_a10);
    ddp_deliv_rec.status_code := p0_a11;
    ddp_deliv_rec.status_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_deliv_rec.active_flag := p0_a13;
    ddp_deliv_rec.private_flag := p0_a14;
    ddp_deliv_rec.owner_user_id := rosetta_g_miss_num_map(p0_a15);
    ddp_deliv_rec.fund_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_deliv_rec.fund_source_type := p0_a17;
    ddp_deliv_rec.category_type_id := rosetta_g_miss_num_map(p0_a18);
    ddp_deliv_rec.category_sub_type_id := rosetta_g_miss_num_map(p0_a19);
    ddp_deliv_rec.kit_flag := p0_a20;
    ddp_deliv_rec.inventory_flag := p0_a21;
    ddp_deliv_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a22);
    ddp_deliv_rec.inventory_item_org_id := rosetta_g_miss_num_map(p0_a23);
    ddp_deliv_rec.pricelist_header_id := rosetta_g_miss_num_map(p0_a24);
    ddp_deliv_rec.pricelist_line_id := rosetta_g_miss_num_map(p0_a25);
    ddp_deliv_rec.actual_avail_from_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_deliv_rec.actual_avail_to_date := rosetta_g_miss_date_in_map(p0_a27);
    ddp_deliv_rec.forecasted_complete_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_deliv_rec.actual_complete_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_deliv_rec.transaction_currency_code := p0_a30;
    ddp_deliv_rec.functional_currency_code := p0_a31;
    ddp_deliv_rec.budget_amount_tc := rosetta_g_miss_num_map(p0_a32);
    ddp_deliv_rec.budget_amount_fc := rosetta_g_miss_num_map(p0_a33);
    ddp_deliv_rec.replaced_by_deliverable_id := rosetta_g_miss_num_map(p0_a34);
    ddp_deliv_rec.can_fulfill_electronic_flag := p0_a35;
    ddp_deliv_rec.can_fulfill_physical_flag := p0_a36;
    ddp_deliv_rec.jtf_amv_item_id := rosetta_g_miss_num_map(p0_a37);
    ddp_deliv_rec.non_inv_ctrl_code := p0_a38;
    ddp_deliv_rec.non_inv_quantity_on_hand := rosetta_g_miss_num_map(p0_a39);
    ddp_deliv_rec.non_inv_quantity_on_order := rosetta_g_miss_num_map(p0_a40);
    ddp_deliv_rec.non_inv_quantity_on_reserve := rosetta_g_miss_num_map(p0_a41);
    ddp_deliv_rec.chargeback_amount := rosetta_g_miss_num_map(p0_a42);
    ddp_deliv_rec.chargeback_uom := p0_a43;
    ddp_deliv_rec.chargeback_amount_curr_code := p0_a44;
    ddp_deliv_rec.deliverable_code := p0_a45;
    ddp_deliv_rec.deliverable_pick_flag := p0_a46;
    ddp_deliv_rec.currency_code := p0_a47;
    ddp_deliv_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a48);
    ddp_deliv_rec.actual_cost := rosetta_g_miss_num_map(p0_a49);
    ddp_deliv_rec.forecasted_responses := rosetta_g_miss_num_map(p0_a50);
    ddp_deliv_rec.actual_responses := rosetta_g_miss_num_map(p0_a51);
    ddp_deliv_rec.country := p0_a52;
    ddp_deliv_rec.default_approver_id := rosetta_g_miss_num_map(p0_a53);
    ddp_deliv_rec.attribute_category := p0_a54;
    ddp_deliv_rec.attribute1 := p0_a55;
    ddp_deliv_rec.attribute2 := p0_a56;
    ddp_deliv_rec.attribute3 := p0_a57;
    ddp_deliv_rec.attribute4 := p0_a58;
    ddp_deliv_rec.attribute5 := p0_a59;
    ddp_deliv_rec.attribute6 := p0_a60;
    ddp_deliv_rec.attribute7 := p0_a61;
    ddp_deliv_rec.attribute8 := p0_a62;
    ddp_deliv_rec.attribute9 := p0_a63;
    ddp_deliv_rec.attribute10 := p0_a64;
    ddp_deliv_rec.attribute11 := p0_a65;
    ddp_deliv_rec.attribute12 := p0_a66;
    ddp_deliv_rec.attribute13 := p0_a67;
    ddp_deliv_rec.attribute14 := p0_a68;
    ddp_deliv_rec.attribute15 := p0_a69;
    ddp_deliv_rec.deliverable_name := p0_a70;
    ddp_deliv_rec.description := p0_a71;
    ddp_deliv_rec.start_period_name := p0_a72;
    ddp_deliv_rec.end_period_name := p0_a73;
    ddp_deliv_rec.deliverable_calendar := p0_a74;
    ddp_deliv_rec.country_id := rosetta_g_miss_num_map(p0_a75);
    ddp_deliv_rec.setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_deliv_rec.item_number := p0_a77;
    ddp_deliv_rec.associate_flag := p0_a78;
    ddp_deliv_rec.master_object_id := rosetta_g_miss_num_map(p0_a79);
    ddp_deliv_rec.master_object_type := p0_a80;
    ddp_deliv_rec.email_content_type := p0_a81;



    -- here's the delegated call to the old PL/SQL routine
    ams_deliverable_pvt.check_deliv_items(ddp_deliv_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_deliv_record(x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  DATE := fnd_api.g_miss_date
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  NUMBER := 0-1962.0724
    , p0_a49  NUMBER := 0-1962.0724
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  NUMBER := 0-1962.0724
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  NUMBER := 0-1962.0724
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  NUMBER := 0-1962.0724
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  DATE := fnd_api.g_miss_date
    , p1_a2  NUMBER := 0-1962.0724
    , p1_a3  DATE := fnd_api.g_miss_date
    , p1_a4  NUMBER := 0-1962.0724
    , p1_a5  NUMBER := 0-1962.0724
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  NUMBER := 0-1962.0724
    , p1_a19  NUMBER := 0-1962.0724
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  NUMBER := 0-1962.0724
    , p1_a23  NUMBER := 0-1962.0724
    , p1_a24  NUMBER := 0-1962.0724
    , p1_a25  NUMBER := 0-1962.0724
    , p1_a26  DATE := fnd_api.g_miss_date
    , p1_a27  DATE := fnd_api.g_miss_date
    , p1_a28  DATE := fnd_api.g_miss_date
    , p1_a29  DATE := fnd_api.g_miss_date
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  NUMBER := 0-1962.0724
    , p1_a33  NUMBER := 0-1962.0724
    , p1_a34  NUMBER := 0-1962.0724
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  VARCHAR2 := fnd_api.g_miss_char
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  VARCHAR2 := fnd_api.g_miss_char
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  NUMBER := 0-1962.0724
    , p1_a41  NUMBER := 0-1962.0724
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  VARCHAR2 := fnd_api.g_miss_char
    , p1_a44  VARCHAR2 := fnd_api.g_miss_char
    , p1_a45  VARCHAR2 := fnd_api.g_miss_char
    , p1_a46  VARCHAR2 := fnd_api.g_miss_char
    , p1_a47  VARCHAR2 := fnd_api.g_miss_char
    , p1_a48  NUMBER := 0-1962.0724
    , p1_a49  NUMBER := 0-1962.0724
    , p1_a50  NUMBER := 0-1962.0724
    , p1_a51  NUMBER := 0-1962.0724
    , p1_a52  VARCHAR2 := fnd_api.g_miss_char
    , p1_a53  NUMBER := 0-1962.0724
    , p1_a54  VARCHAR2 := fnd_api.g_miss_char
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  VARCHAR2 := fnd_api.g_miss_char
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  VARCHAR2 := fnd_api.g_miss_char
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  NUMBER := 0-1962.0724
    , p1_a76  NUMBER := 0-1962.0724
    , p1_a77  VARCHAR2 := fnd_api.g_miss_char
    , p1_a78  VARCHAR2 := fnd_api.g_miss_char
    , p1_a79  NUMBER := 0-1962.0724
    , p1_a80  VARCHAR2 := fnd_api.g_miss_char
    , p1_a81  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_deliv_rec ams_deliverable_pvt.deliv_rec_type;
    ddp_complete_rec ams_deliverable_pvt.deliv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_deliv_rec.deliverable_id := rosetta_g_miss_num_map(p0_a0);
    ddp_deliv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_deliv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_deliv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_deliv_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_deliv_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_deliv_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_deliv_rec.language_code := p0_a7;
    ddp_deliv_rec.version := p0_a8;
    ddp_deliv_rec.application_id := rosetta_g_miss_num_map(p0_a9);
    ddp_deliv_rec.user_status_id := rosetta_g_miss_num_map(p0_a10);
    ddp_deliv_rec.status_code := p0_a11;
    ddp_deliv_rec.status_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_deliv_rec.active_flag := p0_a13;
    ddp_deliv_rec.private_flag := p0_a14;
    ddp_deliv_rec.owner_user_id := rosetta_g_miss_num_map(p0_a15);
    ddp_deliv_rec.fund_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_deliv_rec.fund_source_type := p0_a17;
    ddp_deliv_rec.category_type_id := rosetta_g_miss_num_map(p0_a18);
    ddp_deliv_rec.category_sub_type_id := rosetta_g_miss_num_map(p0_a19);
    ddp_deliv_rec.kit_flag := p0_a20;
    ddp_deliv_rec.inventory_flag := p0_a21;
    ddp_deliv_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a22);
    ddp_deliv_rec.inventory_item_org_id := rosetta_g_miss_num_map(p0_a23);
    ddp_deliv_rec.pricelist_header_id := rosetta_g_miss_num_map(p0_a24);
    ddp_deliv_rec.pricelist_line_id := rosetta_g_miss_num_map(p0_a25);
    ddp_deliv_rec.actual_avail_from_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_deliv_rec.actual_avail_to_date := rosetta_g_miss_date_in_map(p0_a27);
    ddp_deliv_rec.forecasted_complete_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_deliv_rec.actual_complete_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_deliv_rec.transaction_currency_code := p0_a30;
    ddp_deliv_rec.functional_currency_code := p0_a31;
    ddp_deliv_rec.budget_amount_tc := rosetta_g_miss_num_map(p0_a32);
    ddp_deliv_rec.budget_amount_fc := rosetta_g_miss_num_map(p0_a33);
    ddp_deliv_rec.replaced_by_deliverable_id := rosetta_g_miss_num_map(p0_a34);
    ddp_deliv_rec.can_fulfill_electronic_flag := p0_a35;
    ddp_deliv_rec.can_fulfill_physical_flag := p0_a36;
    ddp_deliv_rec.jtf_amv_item_id := rosetta_g_miss_num_map(p0_a37);
    ddp_deliv_rec.non_inv_ctrl_code := p0_a38;
    ddp_deliv_rec.non_inv_quantity_on_hand := rosetta_g_miss_num_map(p0_a39);
    ddp_deliv_rec.non_inv_quantity_on_order := rosetta_g_miss_num_map(p0_a40);
    ddp_deliv_rec.non_inv_quantity_on_reserve := rosetta_g_miss_num_map(p0_a41);
    ddp_deliv_rec.chargeback_amount := rosetta_g_miss_num_map(p0_a42);
    ddp_deliv_rec.chargeback_uom := p0_a43;
    ddp_deliv_rec.chargeback_amount_curr_code := p0_a44;
    ddp_deliv_rec.deliverable_code := p0_a45;
    ddp_deliv_rec.deliverable_pick_flag := p0_a46;
    ddp_deliv_rec.currency_code := p0_a47;
    ddp_deliv_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a48);
    ddp_deliv_rec.actual_cost := rosetta_g_miss_num_map(p0_a49);
    ddp_deliv_rec.forecasted_responses := rosetta_g_miss_num_map(p0_a50);
    ddp_deliv_rec.actual_responses := rosetta_g_miss_num_map(p0_a51);
    ddp_deliv_rec.country := p0_a52;
    ddp_deliv_rec.default_approver_id := rosetta_g_miss_num_map(p0_a53);
    ddp_deliv_rec.attribute_category := p0_a54;
    ddp_deliv_rec.attribute1 := p0_a55;
    ddp_deliv_rec.attribute2 := p0_a56;
    ddp_deliv_rec.attribute3 := p0_a57;
    ddp_deliv_rec.attribute4 := p0_a58;
    ddp_deliv_rec.attribute5 := p0_a59;
    ddp_deliv_rec.attribute6 := p0_a60;
    ddp_deliv_rec.attribute7 := p0_a61;
    ddp_deliv_rec.attribute8 := p0_a62;
    ddp_deliv_rec.attribute9 := p0_a63;
    ddp_deliv_rec.attribute10 := p0_a64;
    ddp_deliv_rec.attribute11 := p0_a65;
    ddp_deliv_rec.attribute12 := p0_a66;
    ddp_deliv_rec.attribute13 := p0_a67;
    ddp_deliv_rec.attribute14 := p0_a68;
    ddp_deliv_rec.attribute15 := p0_a69;
    ddp_deliv_rec.deliverable_name := p0_a70;
    ddp_deliv_rec.description := p0_a71;
    ddp_deliv_rec.start_period_name := p0_a72;
    ddp_deliv_rec.end_period_name := p0_a73;
    ddp_deliv_rec.deliverable_calendar := p0_a74;
    ddp_deliv_rec.country_id := rosetta_g_miss_num_map(p0_a75);
    ddp_deliv_rec.setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_deliv_rec.item_number := p0_a77;
    ddp_deliv_rec.associate_flag := p0_a78;
    ddp_deliv_rec.master_object_id := rosetta_g_miss_num_map(p0_a79);
    ddp_deliv_rec.master_object_type := p0_a80;
    ddp_deliv_rec.email_content_type := p0_a81;

    ddp_complete_rec.deliverable_id := rosetta_g_miss_num_map(p1_a0);
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.last_updated_by := rosetta_g_miss_num_map(p1_a2);
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.created_by := rosetta_g_miss_num_map(p1_a4);
    ddp_complete_rec.last_update_login := rosetta_g_miss_num_map(p1_a5);
    ddp_complete_rec.object_version_number := rosetta_g_miss_num_map(p1_a6);
    ddp_complete_rec.language_code := p1_a7;
    ddp_complete_rec.version := p1_a8;
    ddp_complete_rec.application_id := rosetta_g_miss_num_map(p1_a9);
    ddp_complete_rec.user_status_id := rosetta_g_miss_num_map(p1_a10);
    ddp_complete_rec.status_code := p1_a11;
    ddp_complete_rec.status_date := rosetta_g_miss_date_in_map(p1_a12);
    ddp_complete_rec.active_flag := p1_a13;
    ddp_complete_rec.private_flag := p1_a14;
    ddp_complete_rec.owner_user_id := rosetta_g_miss_num_map(p1_a15);
    ddp_complete_rec.fund_source_id := rosetta_g_miss_num_map(p1_a16);
    ddp_complete_rec.fund_source_type := p1_a17;
    ddp_complete_rec.category_type_id := rosetta_g_miss_num_map(p1_a18);
    ddp_complete_rec.category_sub_type_id := rosetta_g_miss_num_map(p1_a19);
    ddp_complete_rec.kit_flag := p1_a20;
    ddp_complete_rec.inventory_flag := p1_a21;
    ddp_complete_rec.inventory_item_id := rosetta_g_miss_num_map(p1_a22);
    ddp_complete_rec.inventory_item_org_id := rosetta_g_miss_num_map(p1_a23);
    ddp_complete_rec.pricelist_header_id := rosetta_g_miss_num_map(p1_a24);
    ddp_complete_rec.pricelist_line_id := rosetta_g_miss_num_map(p1_a25);
    ddp_complete_rec.actual_avail_from_date := rosetta_g_miss_date_in_map(p1_a26);
    ddp_complete_rec.actual_avail_to_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_complete_rec.forecasted_complete_date := rosetta_g_miss_date_in_map(p1_a28);
    ddp_complete_rec.actual_complete_date := rosetta_g_miss_date_in_map(p1_a29);
    ddp_complete_rec.transaction_currency_code := p1_a30;
    ddp_complete_rec.functional_currency_code := p1_a31;
    ddp_complete_rec.budget_amount_tc := rosetta_g_miss_num_map(p1_a32);
    ddp_complete_rec.budget_amount_fc := rosetta_g_miss_num_map(p1_a33);
    ddp_complete_rec.replaced_by_deliverable_id := rosetta_g_miss_num_map(p1_a34);
    ddp_complete_rec.can_fulfill_electronic_flag := p1_a35;
    ddp_complete_rec.can_fulfill_physical_flag := p1_a36;
    ddp_complete_rec.jtf_amv_item_id := rosetta_g_miss_num_map(p1_a37);
    ddp_complete_rec.non_inv_ctrl_code := p1_a38;
    ddp_complete_rec.non_inv_quantity_on_hand := rosetta_g_miss_num_map(p1_a39);
    ddp_complete_rec.non_inv_quantity_on_order := rosetta_g_miss_num_map(p1_a40);
    ddp_complete_rec.non_inv_quantity_on_reserve := rosetta_g_miss_num_map(p1_a41);
    ddp_complete_rec.chargeback_amount := rosetta_g_miss_num_map(p1_a42);
    ddp_complete_rec.chargeback_uom := p1_a43;
    ddp_complete_rec.chargeback_amount_curr_code := p1_a44;
    ddp_complete_rec.deliverable_code := p1_a45;
    ddp_complete_rec.deliverable_pick_flag := p1_a46;
    ddp_complete_rec.currency_code := p1_a47;
    ddp_complete_rec.forecasted_cost := rosetta_g_miss_num_map(p1_a48);
    ddp_complete_rec.actual_cost := rosetta_g_miss_num_map(p1_a49);
    ddp_complete_rec.forecasted_responses := rosetta_g_miss_num_map(p1_a50);
    ddp_complete_rec.actual_responses := rosetta_g_miss_num_map(p1_a51);
    ddp_complete_rec.country := p1_a52;
    ddp_complete_rec.default_approver_id := rosetta_g_miss_num_map(p1_a53);
    ddp_complete_rec.attribute_category := p1_a54;
    ddp_complete_rec.attribute1 := p1_a55;
    ddp_complete_rec.attribute2 := p1_a56;
    ddp_complete_rec.attribute3 := p1_a57;
    ddp_complete_rec.attribute4 := p1_a58;
    ddp_complete_rec.attribute5 := p1_a59;
    ddp_complete_rec.attribute6 := p1_a60;
    ddp_complete_rec.attribute7 := p1_a61;
    ddp_complete_rec.attribute8 := p1_a62;
    ddp_complete_rec.attribute9 := p1_a63;
    ddp_complete_rec.attribute10 := p1_a64;
    ddp_complete_rec.attribute11 := p1_a65;
    ddp_complete_rec.attribute12 := p1_a66;
    ddp_complete_rec.attribute13 := p1_a67;
    ddp_complete_rec.attribute14 := p1_a68;
    ddp_complete_rec.attribute15 := p1_a69;
    ddp_complete_rec.deliverable_name := p1_a70;
    ddp_complete_rec.description := p1_a71;
    ddp_complete_rec.start_period_name := p1_a72;
    ddp_complete_rec.end_period_name := p1_a73;
    ddp_complete_rec.deliverable_calendar := p1_a74;
    ddp_complete_rec.country_id := rosetta_g_miss_num_map(p1_a75);
    ddp_complete_rec.setup_id := rosetta_g_miss_num_map(p1_a76);
    ddp_complete_rec.item_number := p1_a77;
    ddp_complete_rec.associate_flag := p1_a78;
    ddp_complete_rec.master_object_id := rosetta_g_miss_num_map(p1_a79);
    ddp_complete_rec.master_object_type := p1_a80;
    ddp_complete_rec.email_content_type := p1_a81;


    -- here's the delegated call to the old PL/SQL routine
    ams_deliverable_pvt.check_deliv_record(ddp_deliv_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_deliv_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  VARCHAR2
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  DATE
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  NUMBER
    , p0_a16 out nocopy  NUMBER
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  DATE
    , p0_a27 out nocopy  DATE
    , p0_a28 out nocopy  DATE
    , p0_a29 out nocopy  DATE
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  NUMBER
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  NUMBER
    , p0_a40 out nocopy  NUMBER
    , p0_a41 out nocopy  NUMBER
    , p0_a42 out nocopy  NUMBER
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  VARCHAR2
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  NUMBER
    , p0_a49 out nocopy  NUMBER
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  VARCHAR2
    , p0_a53 out nocopy  NUMBER
    , p0_a54 out nocopy  VARCHAR2
    , p0_a55 out nocopy  VARCHAR2
    , p0_a56 out nocopy  VARCHAR2
    , p0_a57 out nocopy  VARCHAR2
    , p0_a58 out nocopy  VARCHAR2
    , p0_a59 out nocopy  VARCHAR2
    , p0_a60 out nocopy  VARCHAR2
    , p0_a61 out nocopy  VARCHAR2
    , p0_a62 out nocopy  VARCHAR2
    , p0_a63 out nocopy  VARCHAR2
    , p0_a64 out nocopy  VARCHAR2
    , p0_a65 out nocopy  VARCHAR2
    , p0_a66 out nocopy  VARCHAR2
    , p0_a67 out nocopy  VARCHAR2
    , p0_a68 out nocopy  VARCHAR2
    , p0_a69 out nocopy  VARCHAR2
    , p0_a70 out nocopy  VARCHAR2
    , p0_a71 out nocopy  VARCHAR2
    , p0_a72 out nocopy  VARCHAR2
    , p0_a73 out nocopy  VARCHAR2
    , p0_a74 out nocopy  VARCHAR2
    , p0_a75 out nocopy  NUMBER
    , p0_a76 out nocopy  NUMBER
    , p0_a77 out nocopy  VARCHAR2
    , p0_a78 out nocopy  VARCHAR2
    , p0_a79 out nocopy  NUMBER
    , p0_a80 out nocopy  VARCHAR2
    , p0_a81 out nocopy  VARCHAR2
  )

  as
    ddx_deliv_rec ams_deliverable_pvt.deliv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_deliverable_pvt.init_deliv_rec(ddx_deliv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_deliv_rec.deliverable_id);
    p0_a1 := ddx_deliv_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_deliv_rec.last_updated_by);
    p0_a3 := ddx_deliv_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_deliv_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_deliv_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_deliv_rec.object_version_number);
    p0_a7 := ddx_deliv_rec.language_code;
    p0_a8 := ddx_deliv_rec.version;
    p0_a9 := rosetta_g_miss_num_map(ddx_deliv_rec.application_id);
    p0_a10 := rosetta_g_miss_num_map(ddx_deliv_rec.user_status_id);
    p0_a11 := ddx_deliv_rec.status_code;
    p0_a12 := ddx_deliv_rec.status_date;
    p0_a13 := ddx_deliv_rec.active_flag;
    p0_a14 := ddx_deliv_rec.private_flag;
    p0_a15 := rosetta_g_miss_num_map(ddx_deliv_rec.owner_user_id);
    p0_a16 := rosetta_g_miss_num_map(ddx_deliv_rec.fund_source_id);
    p0_a17 := ddx_deliv_rec.fund_source_type;
    p0_a18 := rosetta_g_miss_num_map(ddx_deliv_rec.category_type_id);
    p0_a19 := rosetta_g_miss_num_map(ddx_deliv_rec.category_sub_type_id);
    p0_a20 := ddx_deliv_rec.kit_flag;
    p0_a21 := ddx_deliv_rec.inventory_flag;
    p0_a22 := rosetta_g_miss_num_map(ddx_deliv_rec.inventory_item_id);
    p0_a23 := rosetta_g_miss_num_map(ddx_deliv_rec.inventory_item_org_id);
    p0_a24 := rosetta_g_miss_num_map(ddx_deliv_rec.pricelist_header_id);
    p0_a25 := rosetta_g_miss_num_map(ddx_deliv_rec.pricelist_line_id);
    p0_a26 := ddx_deliv_rec.actual_avail_from_date;
    p0_a27 := ddx_deliv_rec.actual_avail_to_date;
    p0_a28 := ddx_deliv_rec.forecasted_complete_date;
    p0_a29 := ddx_deliv_rec.actual_complete_date;
    p0_a30 := ddx_deliv_rec.transaction_currency_code;
    p0_a31 := ddx_deliv_rec.functional_currency_code;
    p0_a32 := rosetta_g_miss_num_map(ddx_deliv_rec.budget_amount_tc);
    p0_a33 := rosetta_g_miss_num_map(ddx_deliv_rec.budget_amount_fc);
    p0_a34 := rosetta_g_miss_num_map(ddx_deliv_rec.replaced_by_deliverable_id);
    p0_a35 := ddx_deliv_rec.can_fulfill_electronic_flag;
    p0_a36 := ddx_deliv_rec.can_fulfill_physical_flag;
    p0_a37 := rosetta_g_miss_num_map(ddx_deliv_rec.jtf_amv_item_id);
    p0_a38 := ddx_deliv_rec.non_inv_ctrl_code;
    p0_a39 := rosetta_g_miss_num_map(ddx_deliv_rec.non_inv_quantity_on_hand);
    p0_a40 := rosetta_g_miss_num_map(ddx_deliv_rec.non_inv_quantity_on_order);
    p0_a41 := rosetta_g_miss_num_map(ddx_deliv_rec.non_inv_quantity_on_reserve);
    p0_a42 := rosetta_g_miss_num_map(ddx_deliv_rec.chargeback_amount);
    p0_a43 := ddx_deliv_rec.chargeback_uom;
    p0_a44 := ddx_deliv_rec.chargeback_amount_curr_code;
    p0_a45 := ddx_deliv_rec.deliverable_code;
    p0_a46 := ddx_deliv_rec.deliverable_pick_flag;
    p0_a47 := ddx_deliv_rec.currency_code;
    p0_a48 := rosetta_g_miss_num_map(ddx_deliv_rec.forecasted_cost);
    p0_a49 := rosetta_g_miss_num_map(ddx_deliv_rec.actual_cost);
    p0_a50 := rosetta_g_miss_num_map(ddx_deliv_rec.forecasted_responses);
    p0_a51 := rosetta_g_miss_num_map(ddx_deliv_rec.actual_responses);
    p0_a52 := ddx_deliv_rec.country;
    p0_a53 := rosetta_g_miss_num_map(ddx_deliv_rec.default_approver_id);
    p0_a54 := ddx_deliv_rec.attribute_category;
    p0_a55 := ddx_deliv_rec.attribute1;
    p0_a56 := ddx_deliv_rec.attribute2;
    p0_a57 := ddx_deliv_rec.attribute3;
    p0_a58 := ddx_deliv_rec.attribute4;
    p0_a59 := ddx_deliv_rec.attribute5;
    p0_a60 := ddx_deliv_rec.attribute6;
    p0_a61 := ddx_deliv_rec.attribute7;
    p0_a62 := ddx_deliv_rec.attribute8;
    p0_a63 := ddx_deliv_rec.attribute9;
    p0_a64 := ddx_deliv_rec.attribute10;
    p0_a65 := ddx_deliv_rec.attribute11;
    p0_a66 := ddx_deliv_rec.attribute12;
    p0_a67 := ddx_deliv_rec.attribute13;
    p0_a68 := ddx_deliv_rec.attribute14;
    p0_a69 := ddx_deliv_rec.attribute15;
    p0_a70 := ddx_deliv_rec.deliverable_name;
    p0_a71 := ddx_deliv_rec.description;
    p0_a72 := ddx_deliv_rec.start_period_name;
    p0_a73 := ddx_deliv_rec.end_period_name;
    p0_a74 := ddx_deliv_rec.deliverable_calendar;
    p0_a75 := rosetta_g_miss_num_map(ddx_deliv_rec.country_id);
    p0_a76 := rosetta_g_miss_num_map(ddx_deliv_rec.setup_id);
    p0_a77 := ddx_deliv_rec.item_number;
    p0_a78 := ddx_deliv_rec.associate_flag;
    p0_a79 := rosetta_g_miss_num_map(ddx_deliv_rec.master_object_id);
    p0_a80 := ddx_deliv_rec.master_object_type;
    p0_a81 := ddx_deliv_rec.email_content_type;
  end;

  procedure complete_deliv_rec(p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  VARCHAR2
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  DATE
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  NUMBER
    , p1_a16 out nocopy  NUMBER
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  DATE
    , p1_a27 out nocopy  DATE
    , p1_a28 out nocopy  DATE
    , p1_a29 out nocopy  DATE
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  NUMBER
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  NUMBER
    , p1_a40 out nocopy  NUMBER
    , p1_a41 out nocopy  NUMBER
    , p1_a42 out nocopy  NUMBER
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  VARCHAR2
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  NUMBER
    , p1_a49 out nocopy  NUMBER
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  VARCHAR2
    , p1_a53 out nocopy  NUMBER
    , p1_a54 out nocopy  VARCHAR2
    , p1_a55 out nocopy  VARCHAR2
    , p1_a56 out nocopy  VARCHAR2
    , p1_a57 out nocopy  VARCHAR2
    , p1_a58 out nocopy  VARCHAR2
    , p1_a59 out nocopy  VARCHAR2
    , p1_a60 out nocopy  VARCHAR2
    , p1_a61 out nocopy  VARCHAR2
    , p1_a62 out nocopy  VARCHAR2
    , p1_a63 out nocopy  VARCHAR2
    , p1_a64 out nocopy  VARCHAR2
    , p1_a65 out nocopy  VARCHAR2
    , p1_a66 out nocopy  VARCHAR2
    , p1_a67 out nocopy  VARCHAR2
    , p1_a68 out nocopy  VARCHAR2
    , p1_a69 out nocopy  VARCHAR2
    , p1_a70 out nocopy  VARCHAR2
    , p1_a71 out nocopy  VARCHAR2
    , p1_a72 out nocopy  VARCHAR2
    , p1_a73 out nocopy  VARCHAR2
    , p1_a74 out nocopy  VARCHAR2
    , p1_a75 out nocopy  NUMBER
    , p1_a76 out nocopy  NUMBER
    , p1_a77 out nocopy  VARCHAR2
    , p1_a78 out nocopy  VARCHAR2
    , p1_a79 out nocopy  NUMBER
    , p1_a80 out nocopy  VARCHAR2
    , p1_a81 out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  DATE := fnd_api.g_miss_date
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  NUMBER := 0-1962.0724
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  NUMBER := 0-1962.0724
    , p0_a23  NUMBER := 0-1962.0724
    , p0_a24  NUMBER := 0-1962.0724
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  DATE := fnd_api.g_miss_date
    , p0_a28  DATE := fnd_api.g_miss_date
    , p0_a29  DATE := fnd_api.g_miss_date
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  NUMBER := 0-1962.0724
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  NUMBER := 0-1962.0724
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  NUMBER := 0-1962.0724
    , p0_a49  NUMBER := 0-1962.0724
    , p0_a50  NUMBER := 0-1962.0724
    , p0_a51  NUMBER := 0-1962.0724
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  NUMBER := 0-1962.0724
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  NUMBER := 0-1962.0724
    , p0_a76  NUMBER := 0-1962.0724
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_deliv_rec ams_deliverable_pvt.deliv_rec_type;
    ddx_complete_rec ams_deliverable_pvt.deliv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_deliv_rec.deliverable_id := rosetta_g_miss_num_map(p0_a0);
    ddp_deliv_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_deliv_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_deliv_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_deliv_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_deliv_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_deliv_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_deliv_rec.language_code := p0_a7;
    ddp_deliv_rec.version := p0_a8;
    ddp_deliv_rec.application_id := rosetta_g_miss_num_map(p0_a9);
    ddp_deliv_rec.user_status_id := rosetta_g_miss_num_map(p0_a10);
    ddp_deliv_rec.status_code := p0_a11;
    ddp_deliv_rec.status_date := rosetta_g_miss_date_in_map(p0_a12);
    ddp_deliv_rec.active_flag := p0_a13;
    ddp_deliv_rec.private_flag := p0_a14;
    ddp_deliv_rec.owner_user_id := rosetta_g_miss_num_map(p0_a15);
    ddp_deliv_rec.fund_source_id := rosetta_g_miss_num_map(p0_a16);
    ddp_deliv_rec.fund_source_type := p0_a17;
    ddp_deliv_rec.category_type_id := rosetta_g_miss_num_map(p0_a18);
    ddp_deliv_rec.category_sub_type_id := rosetta_g_miss_num_map(p0_a19);
    ddp_deliv_rec.kit_flag := p0_a20;
    ddp_deliv_rec.inventory_flag := p0_a21;
    ddp_deliv_rec.inventory_item_id := rosetta_g_miss_num_map(p0_a22);
    ddp_deliv_rec.inventory_item_org_id := rosetta_g_miss_num_map(p0_a23);
    ddp_deliv_rec.pricelist_header_id := rosetta_g_miss_num_map(p0_a24);
    ddp_deliv_rec.pricelist_line_id := rosetta_g_miss_num_map(p0_a25);
    ddp_deliv_rec.actual_avail_from_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_deliv_rec.actual_avail_to_date := rosetta_g_miss_date_in_map(p0_a27);
    ddp_deliv_rec.forecasted_complete_date := rosetta_g_miss_date_in_map(p0_a28);
    ddp_deliv_rec.actual_complete_date := rosetta_g_miss_date_in_map(p0_a29);
    ddp_deliv_rec.transaction_currency_code := p0_a30;
    ddp_deliv_rec.functional_currency_code := p0_a31;
    ddp_deliv_rec.budget_amount_tc := rosetta_g_miss_num_map(p0_a32);
    ddp_deliv_rec.budget_amount_fc := rosetta_g_miss_num_map(p0_a33);
    ddp_deliv_rec.replaced_by_deliverable_id := rosetta_g_miss_num_map(p0_a34);
    ddp_deliv_rec.can_fulfill_electronic_flag := p0_a35;
    ddp_deliv_rec.can_fulfill_physical_flag := p0_a36;
    ddp_deliv_rec.jtf_amv_item_id := rosetta_g_miss_num_map(p0_a37);
    ddp_deliv_rec.non_inv_ctrl_code := p0_a38;
    ddp_deliv_rec.non_inv_quantity_on_hand := rosetta_g_miss_num_map(p0_a39);
    ddp_deliv_rec.non_inv_quantity_on_order := rosetta_g_miss_num_map(p0_a40);
    ddp_deliv_rec.non_inv_quantity_on_reserve := rosetta_g_miss_num_map(p0_a41);
    ddp_deliv_rec.chargeback_amount := rosetta_g_miss_num_map(p0_a42);
    ddp_deliv_rec.chargeback_uom := p0_a43;
    ddp_deliv_rec.chargeback_amount_curr_code := p0_a44;
    ddp_deliv_rec.deliverable_code := p0_a45;
    ddp_deliv_rec.deliverable_pick_flag := p0_a46;
    ddp_deliv_rec.currency_code := p0_a47;
    ddp_deliv_rec.forecasted_cost := rosetta_g_miss_num_map(p0_a48);
    ddp_deliv_rec.actual_cost := rosetta_g_miss_num_map(p0_a49);
    ddp_deliv_rec.forecasted_responses := rosetta_g_miss_num_map(p0_a50);
    ddp_deliv_rec.actual_responses := rosetta_g_miss_num_map(p0_a51);
    ddp_deliv_rec.country := p0_a52;
    ddp_deliv_rec.default_approver_id := rosetta_g_miss_num_map(p0_a53);
    ddp_deliv_rec.attribute_category := p0_a54;
    ddp_deliv_rec.attribute1 := p0_a55;
    ddp_deliv_rec.attribute2 := p0_a56;
    ddp_deliv_rec.attribute3 := p0_a57;
    ddp_deliv_rec.attribute4 := p0_a58;
    ddp_deliv_rec.attribute5 := p0_a59;
    ddp_deliv_rec.attribute6 := p0_a60;
    ddp_deliv_rec.attribute7 := p0_a61;
    ddp_deliv_rec.attribute8 := p0_a62;
    ddp_deliv_rec.attribute9 := p0_a63;
    ddp_deliv_rec.attribute10 := p0_a64;
    ddp_deliv_rec.attribute11 := p0_a65;
    ddp_deliv_rec.attribute12 := p0_a66;
    ddp_deliv_rec.attribute13 := p0_a67;
    ddp_deliv_rec.attribute14 := p0_a68;
    ddp_deliv_rec.attribute15 := p0_a69;
    ddp_deliv_rec.deliverable_name := p0_a70;
    ddp_deliv_rec.description := p0_a71;
    ddp_deliv_rec.start_period_name := p0_a72;
    ddp_deliv_rec.end_period_name := p0_a73;
    ddp_deliv_rec.deliverable_calendar := p0_a74;
    ddp_deliv_rec.country_id := rosetta_g_miss_num_map(p0_a75);
    ddp_deliv_rec.setup_id := rosetta_g_miss_num_map(p0_a76);
    ddp_deliv_rec.item_number := p0_a77;
    ddp_deliv_rec.associate_flag := p0_a78;
    ddp_deliv_rec.master_object_id := rosetta_g_miss_num_map(p0_a79);
    ddp_deliv_rec.master_object_type := p0_a80;
    ddp_deliv_rec.email_content_type := p0_a81;


    -- here's the delegated call to the old PL/SQL routine
    ams_deliverable_pvt.complete_deliv_rec(ddp_deliv_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.deliverable_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := ddx_complete_rec.language_code;
    p1_a8 := ddx_complete_rec.version;
    p1_a9 := rosetta_g_miss_num_map(ddx_complete_rec.application_id);
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.user_status_id);
    p1_a11 := ddx_complete_rec.status_code;
    p1_a12 := ddx_complete_rec.status_date;
    p1_a13 := ddx_complete_rec.active_flag;
    p1_a14 := ddx_complete_rec.private_flag;
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.owner_user_id);
    p1_a16 := rosetta_g_miss_num_map(ddx_complete_rec.fund_source_id);
    p1_a17 := ddx_complete_rec.fund_source_type;
    p1_a18 := rosetta_g_miss_num_map(ddx_complete_rec.category_type_id);
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.category_sub_type_id);
    p1_a20 := ddx_complete_rec.kit_flag;
    p1_a21 := ddx_complete_rec.inventory_flag;
    p1_a22 := rosetta_g_miss_num_map(ddx_complete_rec.inventory_item_id);
    p1_a23 := rosetta_g_miss_num_map(ddx_complete_rec.inventory_item_org_id);
    p1_a24 := rosetta_g_miss_num_map(ddx_complete_rec.pricelist_header_id);
    p1_a25 := rosetta_g_miss_num_map(ddx_complete_rec.pricelist_line_id);
    p1_a26 := ddx_complete_rec.actual_avail_from_date;
    p1_a27 := ddx_complete_rec.actual_avail_to_date;
    p1_a28 := ddx_complete_rec.forecasted_complete_date;
    p1_a29 := ddx_complete_rec.actual_complete_date;
    p1_a30 := ddx_complete_rec.transaction_currency_code;
    p1_a31 := ddx_complete_rec.functional_currency_code;
    p1_a32 := rosetta_g_miss_num_map(ddx_complete_rec.budget_amount_tc);
    p1_a33 := rosetta_g_miss_num_map(ddx_complete_rec.budget_amount_fc);
    p1_a34 := rosetta_g_miss_num_map(ddx_complete_rec.replaced_by_deliverable_id);
    p1_a35 := ddx_complete_rec.can_fulfill_electronic_flag;
    p1_a36 := ddx_complete_rec.can_fulfill_physical_flag;
    p1_a37 := rosetta_g_miss_num_map(ddx_complete_rec.jtf_amv_item_id);
    p1_a38 := ddx_complete_rec.non_inv_ctrl_code;
    p1_a39 := rosetta_g_miss_num_map(ddx_complete_rec.non_inv_quantity_on_hand);
    p1_a40 := rosetta_g_miss_num_map(ddx_complete_rec.non_inv_quantity_on_order);
    p1_a41 := rosetta_g_miss_num_map(ddx_complete_rec.non_inv_quantity_on_reserve);
    p1_a42 := rosetta_g_miss_num_map(ddx_complete_rec.chargeback_amount);
    p1_a43 := ddx_complete_rec.chargeback_uom;
    p1_a44 := ddx_complete_rec.chargeback_amount_curr_code;
    p1_a45 := ddx_complete_rec.deliverable_code;
    p1_a46 := ddx_complete_rec.deliverable_pick_flag;
    p1_a47 := ddx_complete_rec.currency_code;
    p1_a48 := rosetta_g_miss_num_map(ddx_complete_rec.forecasted_cost);
    p1_a49 := rosetta_g_miss_num_map(ddx_complete_rec.actual_cost);
    p1_a50 := rosetta_g_miss_num_map(ddx_complete_rec.forecasted_responses);
    p1_a51 := rosetta_g_miss_num_map(ddx_complete_rec.actual_responses);
    p1_a52 := ddx_complete_rec.country;
    p1_a53 := rosetta_g_miss_num_map(ddx_complete_rec.default_approver_id);
    p1_a54 := ddx_complete_rec.attribute_category;
    p1_a55 := ddx_complete_rec.attribute1;
    p1_a56 := ddx_complete_rec.attribute2;
    p1_a57 := ddx_complete_rec.attribute3;
    p1_a58 := ddx_complete_rec.attribute4;
    p1_a59 := ddx_complete_rec.attribute5;
    p1_a60 := ddx_complete_rec.attribute6;
    p1_a61 := ddx_complete_rec.attribute7;
    p1_a62 := ddx_complete_rec.attribute8;
    p1_a63 := ddx_complete_rec.attribute9;
    p1_a64 := ddx_complete_rec.attribute10;
    p1_a65 := ddx_complete_rec.attribute11;
    p1_a66 := ddx_complete_rec.attribute12;
    p1_a67 := ddx_complete_rec.attribute13;
    p1_a68 := ddx_complete_rec.attribute14;
    p1_a69 := ddx_complete_rec.attribute15;
    p1_a70 := ddx_complete_rec.deliverable_name;
    p1_a71 := ddx_complete_rec.description;
    p1_a72 := ddx_complete_rec.start_period_name;
    p1_a73 := ddx_complete_rec.end_period_name;
    p1_a74 := ddx_complete_rec.deliverable_calendar;
    p1_a75 := rosetta_g_miss_num_map(ddx_complete_rec.country_id);
    p1_a76 := rosetta_g_miss_num_map(ddx_complete_rec.setup_id);
    p1_a77 := ddx_complete_rec.item_number;
    p1_a78 := ddx_complete_rec.associate_flag;
    p1_a79 := rosetta_g_miss_num_map(ddx_complete_rec.master_object_id);
    p1_a80 := ddx_complete_rec.master_object_type;
    p1_a81 := ddx_complete_rec.email_content_type;
  end;

end ams_deliverable_pvt_w;

/
