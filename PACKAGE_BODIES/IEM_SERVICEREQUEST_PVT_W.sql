--------------------------------------------------------
--  DDL for Package Body IEM_SERVICEREQUEST_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SERVICEREQUEST_PVT_W" as
  /* $Header: iemcspkb.pls 115.3 2002/12/23 19:34:53 mrabatin noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p4(t out nocopy iem_servicerequest_pvt.notes_table, a0 JTF_VARCHAR2_TABLE_2000
    , a1 JTF_VARCHAR2_TABLE_32767
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).note := a0(indx);
          t(ddindx).note_detail := a1(indx);
          t(ddindx).note_type := a2(indx);
          t(ddindx).note_context_type_01 := a3(indx);
          t(ddindx).note_context_type_id_01 := a4(indx);
          t(ddindx).note_context_type_02 := a5(indx);
          t(ddindx).note_context_type_id_02 := a6(indx);
          t(ddindx).note_context_type_03 := a7(indx);
          t(ddindx).note_context_type_id_03 := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t iem_servicerequest_pvt.notes_table, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    , a1 out nocopy JTF_VARCHAR2_TABLE_32767
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
    a1 := JTF_VARCHAR2_TABLE_32767();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      a1 := JTF_VARCHAR2_TABLE_32767();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).note;
          a1(indx) := t(ddindx).note_detail;
          a2(indx) := t(ddindx).note_type;
          a3(indx) := t(ddindx).note_context_type_01;
          a4(indx) := t(ddindx).note_context_type_id_01;
          a5(indx) := t(ddindx).note_context_type_02;
          a6(indx) := t(ddindx).note_context_type_id_02;
          a7(indx) := t(ddindx).note_context_type_03;
          a8(indx) := t(ddindx).note_context_type_id_03;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy iem_servicerequest_pvt.contacts_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sr_contact_point_id := a0(indx);
          t(ddindx).party_id := a1(indx);
          t(ddindx).contact_point_id := a2(indx);
          t(ddindx).contact_point_type := a3(indx);
          t(ddindx).primary_flag := a4(indx);
          t(ddindx).contact_type := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t iem_servicerequest_pvt.contacts_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).sr_contact_point_id;
          a1(indx) := t(ddindx).party_id;
          a2(indx) := t(ddindx).contact_point_id;
          a3(indx) := t(ddindx).contact_point_type;
          a4(indx) := t(ddindx).primary_flag;
          a5(indx) := t(ddindx).contact_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_servicerequest_wrap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_user_id  NUMBER
    , p_login_id  NUMBER
    , p_org_id  NUMBER
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p13_a0  DATE
    , p13_a1  NUMBER
    , p13_a2  VARCHAR2
    , p13_a3  NUMBER
    , p13_a4  VARCHAR2
    , p13_a5  NUMBER
    , p13_a6  VARCHAR2
    , p13_a7  NUMBER
    , p13_a8  VARCHAR2
    , p13_a9  DATE
    , p13_a10  NUMBER
    , p13_a11  NUMBER
    , p13_a12  VARCHAR2
    , p13_a13  VARCHAR2
    , p13_a14  VARCHAR2
    , p13_a15  NUMBER
    , p13_a16  VARCHAR2
    , p13_a17  NUMBER
    , p13_a18  VARCHAR2
    , p13_a19  VARCHAR2
    , p13_a20  NUMBER
    , p13_a21  NUMBER
    , p13_a22  VARCHAR2
    , p13_a23  VARCHAR2
    , p13_a24  NUMBER
    , p13_a25  NUMBER
    , p13_a26  NUMBER
    , p13_a27  NUMBER
    , p13_a28  NUMBER
    , p13_a29  NUMBER
    , p13_a30  VARCHAR2
    , p13_a31  NUMBER
    , p13_a32  NUMBER
    , p13_a33  VARCHAR2
    , p13_a34  VARCHAR2
    , p13_a35  VARCHAR2
    , p13_a36  VARCHAR2
    , p13_a37  VARCHAR2
    , p13_a38  VARCHAR2
    , p13_a39  VARCHAR2
    , p13_a40  VARCHAR2
    , p13_a41  VARCHAR2
    , p13_a42  VARCHAR2
    , p13_a43  VARCHAR2
    , p13_a44  VARCHAR2
    , p13_a45  VARCHAR2
    , p13_a46  VARCHAR2
    , p13_a47  VARCHAR2
    , p13_a48  VARCHAR2
    , p13_a49  VARCHAR2
    , p13_a50  VARCHAR2
    , p13_a51  VARCHAR2
    , p13_a52  VARCHAR2
    , p13_a53  VARCHAR2
    , p13_a54  VARCHAR2
    , p13_a55  NUMBER
    , p13_a56  VARCHAR2
    , p13_a57  NUMBER
    , p13_a58  VARCHAR2
    , p13_a59  VARCHAR2
    , p13_a60  DATE
    , p13_a61  NUMBER
    , p13_a62  VARCHAR2
    , p13_a63  VARCHAR2
    , p13_a64  VARCHAR2
    , p13_a65  VARCHAR2
    , p13_a66  VARCHAR2
    , p13_a67  VARCHAR2
    , p13_a68  VARCHAR2
    , p13_a69  VARCHAR2
    , p13_a70  VARCHAR2
    , p13_a71  VARCHAR2
    , p13_a72  VARCHAR2
    , p13_a73  VARCHAR2
    , p13_a74  VARCHAR2
    , p13_a75  VARCHAR2
    , p13_a76  VARCHAR2
    , p13_a77  VARCHAR2
    , p13_a78  NUMBER
    , p13_a79  NUMBER
    , p13_a80  NUMBER
    , p13_a81  NUMBER
    , p13_a82  VARCHAR2
    , p13_a83  DATE
    , p13_a84  VARCHAR2
    , p13_a85  NUMBER
    , p13_a86  NUMBER
    , p13_a87  VARCHAR2
    , p13_a88  NUMBER
    , p13_a89  VARCHAR2
    , p13_a90  NUMBER
    , p13_a91  NUMBER
    , p13_a92  VARCHAR2
    , p13_a93  NUMBER
    , p13_a94  VARCHAR2
    , p13_a95  VARCHAR2
    , p13_a96  VARCHAR2
    , p13_a97  DATE
    , p13_a98  NUMBER
    , p13_a99  NUMBER
    , p13_a100  NUMBER
    , p13_a101  NUMBER
    , p13_a102  NUMBER
    , p13_a103  VARCHAR2
    , p13_a104  NUMBER
    , p13_a105  VARCHAR2
    , p13_a106  NUMBER
    , p13_a107  VARCHAR2
    , p13_a108  NUMBER
    , p13_a109  VARCHAR2
    , p13_a110  VARCHAR2
    , p13_a111  VARCHAR2
    , p13_a112  VARCHAR2
    , p13_a113  VARCHAR2
    , p13_a114  VARCHAR2
    , p13_a115  NUMBER
    , p13_a116  NUMBER
    , p13_a117  VARCHAR2
    , p13_a118  NUMBER
    , p13_a119  NUMBER
    , p13_a120  VARCHAR2
    , p13_a121  VARCHAR2
    , p13_a122  VARCHAR2
    , p13_a123  VARCHAR2
    , p13_a124  VARCHAR2
    , p13_a125  VARCHAR2
    , p14_a0 JTF_VARCHAR2_TABLE_2000
    , p14_a1 JTF_VARCHAR2_TABLE_32767
    , p14_a2 JTF_VARCHAR2_TABLE_300
    , p14_a3 JTF_VARCHAR2_TABLE_100
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_VARCHAR2_TABLE_100
    , p14_a8 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_VARCHAR2_TABLE_100
    , p15_a4 JTF_VARCHAR2_TABLE_100
    , p15_a5 JTF_VARCHAR2_TABLE_100
    , x_request_id out nocopy  NUMBER
    , x_request_number out nocopy  VARCHAR2
    , x_interaction_id out nocopy  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
  )

  as
    ddp_service_request_rec iem_servicerequest_pvt.service_request_rec_type;
    ddp_notes iem_servicerequest_pvt.notes_table;
    ddp_contacts iem_servicerequest_pvt.contacts_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p13_a0);
    ddp_service_request_rec.type_id := p13_a1;
    ddp_service_request_rec.type_name := p13_a2;
    ddp_service_request_rec.status_id := p13_a3;
    ddp_service_request_rec.status_name := p13_a4;
    ddp_service_request_rec.severity_id := p13_a5;
    ddp_service_request_rec.severity_name := p13_a6;
    ddp_service_request_rec.urgency_id := p13_a7;
    ddp_service_request_rec.urgency_name := p13_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p13_a9);
    ddp_service_request_rec.owner_id := p13_a10;
    ddp_service_request_rec.owner_group_id := p13_a11;
    ddp_service_request_rec.publish_flag := p13_a12;
    ddp_service_request_rec.summary := p13_a13;
    ddp_service_request_rec.caller_type := p13_a14;
    ddp_service_request_rec.customer_id := p13_a15;
    ddp_service_request_rec.customer_number := p13_a16;
    ddp_service_request_rec.employee_id := p13_a17;
    ddp_service_request_rec.employee_number := p13_a18;
    ddp_service_request_rec.verify_cp_flag := p13_a19;
    ddp_service_request_rec.customer_product_id := p13_a20;
    ddp_service_request_rec.platform_id := p13_a21;
    ddp_service_request_rec.platform_version := p13_a22;
    ddp_service_request_rec.db_version := p13_a23;
    ddp_service_request_rec.platform_version_id := p13_a24;
    ddp_service_request_rec.cp_component_id := p13_a25;
    ddp_service_request_rec.cp_component_version_id := p13_a26;
    ddp_service_request_rec.cp_subcomponent_id := p13_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p13_a28;
    ddp_service_request_rec.language_id := p13_a29;
    ddp_service_request_rec.language := p13_a30;
    ddp_service_request_rec.cp_ref_number := p13_a31;
    ddp_service_request_rec.inventory_item_id := p13_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p13_a33;
    ddp_service_request_rec.inventory_item_segment1 := p13_a34;
    ddp_service_request_rec.inventory_item_segment2 := p13_a35;
    ddp_service_request_rec.inventory_item_segment3 := p13_a36;
    ddp_service_request_rec.inventory_item_segment4 := p13_a37;
    ddp_service_request_rec.inventory_item_segment5 := p13_a38;
    ddp_service_request_rec.inventory_item_segment6 := p13_a39;
    ddp_service_request_rec.inventory_item_segment7 := p13_a40;
    ddp_service_request_rec.inventory_item_segment8 := p13_a41;
    ddp_service_request_rec.inventory_item_segment9 := p13_a42;
    ddp_service_request_rec.inventory_item_segment10 := p13_a43;
    ddp_service_request_rec.inventory_item_segment11 := p13_a44;
    ddp_service_request_rec.inventory_item_segment12 := p13_a45;
    ddp_service_request_rec.inventory_item_segment13 := p13_a46;
    ddp_service_request_rec.inventory_item_segment14 := p13_a47;
    ddp_service_request_rec.inventory_item_segment15 := p13_a48;
    ddp_service_request_rec.inventory_item_segment16 := p13_a49;
    ddp_service_request_rec.inventory_item_segment17 := p13_a50;
    ddp_service_request_rec.inventory_item_segment18 := p13_a51;
    ddp_service_request_rec.inventory_item_segment19 := p13_a52;
    ddp_service_request_rec.inventory_item_segment20 := p13_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p13_a54;
    ddp_service_request_rec.inventory_org_id := p13_a55;
    ddp_service_request_rec.current_serial_number := p13_a56;
    ddp_service_request_rec.original_order_number := p13_a57;
    ddp_service_request_rec.purchase_order_num := p13_a58;
    ddp_service_request_rec.problem_code := p13_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p13_a60);
    ddp_service_request_rec.install_site_use_id := p13_a61;
    ddp_service_request_rec.request_attribute_1 := p13_a62;
    ddp_service_request_rec.request_attribute_2 := p13_a63;
    ddp_service_request_rec.request_attribute_3 := p13_a64;
    ddp_service_request_rec.request_attribute_4 := p13_a65;
    ddp_service_request_rec.request_attribute_5 := p13_a66;
    ddp_service_request_rec.request_attribute_6 := p13_a67;
    ddp_service_request_rec.request_attribute_7 := p13_a68;
    ddp_service_request_rec.request_attribute_8 := p13_a69;
    ddp_service_request_rec.request_attribute_9 := p13_a70;
    ddp_service_request_rec.request_attribute_10 := p13_a71;
    ddp_service_request_rec.request_attribute_11 := p13_a72;
    ddp_service_request_rec.request_attribute_12 := p13_a73;
    ddp_service_request_rec.request_attribute_13 := p13_a74;
    ddp_service_request_rec.request_attribute_14 := p13_a75;
    ddp_service_request_rec.request_attribute_15 := p13_a76;
    ddp_service_request_rec.request_context := p13_a77;
    ddp_service_request_rec.bill_to_site_use_id := p13_a78;
    ddp_service_request_rec.bill_to_contact_id := p13_a79;
    ddp_service_request_rec.ship_to_site_use_id := p13_a80;
    ddp_service_request_rec.ship_to_contact_id := p13_a81;
    ddp_service_request_rec.resolution_code := p13_a82;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p13_a83);
    ddp_service_request_rec.public_comment_flag := p13_a84;
    ddp_service_request_rec.parent_interaction_id := p13_a85;
    ddp_service_request_rec.contract_service_id := p13_a86;
    ddp_service_request_rec.contract_service_number := p13_a87;
    ddp_service_request_rec.contract_id := p13_a88;
    ddp_service_request_rec.project_number := p13_a89;
    ddp_service_request_rec.qa_collection_plan_id := p13_a90;
    ddp_service_request_rec.account_id := p13_a91;
    ddp_service_request_rec.resource_type := p13_a92;
    ddp_service_request_rec.resource_subtype_id := p13_a93;
    ddp_service_request_rec.cust_po_number := p13_a94;
    ddp_service_request_rec.cust_ticket_number := p13_a95;
    ddp_service_request_rec.sr_creation_channel := p13_a96;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p13_a97);
    ddp_service_request_rec.time_zone_id := p13_a98;
    ddp_service_request_rec.time_difference := p13_a99;
    ddp_service_request_rec.site_id := p13_a100;
    ddp_service_request_rec.customer_site_id := p13_a101;
    ddp_service_request_rec.territory_id := p13_a102;
    ddp_service_request_rec.initialize_flag := p13_a103;
    ddp_service_request_rec.cp_revision_id := p13_a104;
    ddp_service_request_rec.inv_item_revision := p13_a105;
    ddp_service_request_rec.inv_component_id := p13_a106;
    ddp_service_request_rec.inv_component_version := p13_a107;
    ddp_service_request_rec.inv_subcomponent_id := p13_a108;
    ddp_service_request_rec.inv_subcomponent_version := p13_a109;
    ddp_service_request_rec.tier := p13_a110;
    ddp_service_request_rec.tier_version := p13_a111;
    ddp_service_request_rec.operating_system := p13_a112;
    ddp_service_request_rec.operating_system_version := p13_a113;
    ddp_service_request_rec.database := p13_a114;
    ddp_service_request_rec.cust_pref_lang_id := p13_a115;
    ddp_service_request_rec.category_id := p13_a116;
    ddp_service_request_rec.group_type := p13_a117;
    ddp_service_request_rec.group_territory_id := p13_a118;
    ddp_service_request_rec.inv_platform_org_id := p13_a119;
    ddp_service_request_rec.component_version := p13_a120;
    ddp_service_request_rec.subcomponent_version := p13_a121;
    ddp_service_request_rec.product_revision := p13_a122;
    ddp_service_request_rec.comm_pref_code := p13_a123;
    ddp_service_request_rec.cust_pref_lang_code := p13_a124;
    ddp_service_request_rec.last_update_channel := p13_a125;

    iem_servicerequest_pvt_w.rosetta_table_copy_in_p4(ddp_notes, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      );

    iem_servicerequest_pvt_w.rosetta_table_copy_in_p6(ddp_contacts, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      );





    -- here's the delegated call to the old PL/SQL routine
    iem_servicerequest_pvt.create_servicerequest_wrap(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resp_appl_id,
      p_resp_id,
      p_user_id,
      p_login_id,
      p_org_id,
      p_request_id,
      p_request_number,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      x_request_id,
      x_request_number,
      x_interaction_id,
      x_workflow_process_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



















  end;

  procedure update_servicerequest_wrap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_request_number  VARCHAR2
    , p_audit_comments  VARCHAR2
    , p_object_version_number  NUMBER
    , p_resp_appl_id  NUMBER
    , p_resp_id  NUMBER
    , p_last_updated_by  NUMBER
    , p_last_update_login  NUMBER
    , p_last_update_date  date
    , p15_a0  DATE
    , p15_a1  NUMBER
    , p15_a2  VARCHAR2
    , p15_a3  NUMBER
    , p15_a4  VARCHAR2
    , p15_a5  NUMBER
    , p15_a6  VARCHAR2
    , p15_a7  NUMBER
    , p15_a8  VARCHAR2
    , p15_a9  DATE
    , p15_a10  NUMBER
    , p15_a11  NUMBER
    , p15_a12  VARCHAR2
    , p15_a13  VARCHAR2
    , p15_a14  VARCHAR2
    , p15_a15  NUMBER
    , p15_a16  VARCHAR2
    , p15_a17  NUMBER
    , p15_a18  VARCHAR2
    , p15_a19  VARCHAR2
    , p15_a20  NUMBER
    , p15_a21  NUMBER
    , p15_a22  VARCHAR2
    , p15_a23  VARCHAR2
    , p15_a24  NUMBER
    , p15_a25  NUMBER
    , p15_a26  NUMBER
    , p15_a27  NUMBER
    , p15_a28  NUMBER
    , p15_a29  NUMBER
    , p15_a30  VARCHAR2
    , p15_a31  NUMBER
    , p15_a32  NUMBER
    , p15_a33  VARCHAR2
    , p15_a34  VARCHAR2
    , p15_a35  VARCHAR2
    , p15_a36  VARCHAR2
    , p15_a37  VARCHAR2
    , p15_a38  VARCHAR2
    , p15_a39  VARCHAR2
    , p15_a40  VARCHAR2
    , p15_a41  VARCHAR2
    , p15_a42  VARCHAR2
    , p15_a43  VARCHAR2
    , p15_a44  VARCHAR2
    , p15_a45  VARCHAR2
    , p15_a46  VARCHAR2
    , p15_a47  VARCHAR2
    , p15_a48  VARCHAR2
    , p15_a49  VARCHAR2
    , p15_a50  VARCHAR2
    , p15_a51  VARCHAR2
    , p15_a52  VARCHAR2
    , p15_a53  VARCHAR2
    , p15_a54  VARCHAR2
    , p15_a55  NUMBER
    , p15_a56  VARCHAR2
    , p15_a57  NUMBER
    , p15_a58  VARCHAR2
    , p15_a59  VARCHAR2
    , p15_a60  DATE
    , p15_a61  NUMBER
    , p15_a62  VARCHAR2
    , p15_a63  VARCHAR2
    , p15_a64  VARCHAR2
    , p15_a65  VARCHAR2
    , p15_a66  VARCHAR2
    , p15_a67  VARCHAR2
    , p15_a68  VARCHAR2
    , p15_a69  VARCHAR2
    , p15_a70  VARCHAR2
    , p15_a71  VARCHAR2
    , p15_a72  VARCHAR2
    , p15_a73  VARCHAR2
    , p15_a74  VARCHAR2
    , p15_a75  VARCHAR2
    , p15_a76  VARCHAR2
    , p15_a77  VARCHAR2
    , p15_a78  NUMBER
    , p15_a79  NUMBER
    , p15_a80  NUMBER
    , p15_a81  NUMBER
    , p15_a82  VARCHAR2
    , p15_a83  DATE
    , p15_a84  VARCHAR2
    , p15_a85  NUMBER
    , p15_a86  NUMBER
    , p15_a87  VARCHAR2
    , p15_a88  NUMBER
    , p15_a89  VARCHAR2
    , p15_a90  NUMBER
    , p15_a91  NUMBER
    , p15_a92  VARCHAR2
    , p15_a93  NUMBER
    , p15_a94  VARCHAR2
    , p15_a95  VARCHAR2
    , p15_a96  VARCHAR2
    , p15_a97  DATE
    , p15_a98  NUMBER
    , p15_a99  NUMBER
    , p15_a100  NUMBER
    , p15_a101  NUMBER
    , p15_a102  NUMBER
    , p15_a103  VARCHAR2
    , p15_a104  NUMBER
    , p15_a105  VARCHAR2
    , p15_a106  NUMBER
    , p15_a107  VARCHAR2
    , p15_a108  NUMBER
    , p15_a109  VARCHAR2
    , p15_a110  VARCHAR2
    , p15_a111  VARCHAR2
    , p15_a112  VARCHAR2
    , p15_a113  VARCHAR2
    , p15_a114  VARCHAR2
    , p15_a115  NUMBER
    , p15_a116  NUMBER
    , p15_a117  VARCHAR2
    , p15_a118  NUMBER
    , p15_a119  NUMBER
    , p15_a120  VARCHAR2
    , p15_a121  VARCHAR2
    , p15_a122  VARCHAR2
    , p15_a123  VARCHAR2
    , p15_a124  VARCHAR2
    , p15_a125  VARCHAR2
    , p16_a0 JTF_VARCHAR2_TABLE_2000
    , p16_a1 JTF_VARCHAR2_TABLE_32767
    , p16_a2 JTF_VARCHAR2_TABLE_300
    , p16_a3 JTF_VARCHAR2_TABLE_100
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_VARCHAR2_TABLE_100
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_VARCHAR2_TABLE_100
    , p16_a8 JTF_NUMBER_TABLE
    , p17_a0 JTF_NUMBER_TABLE
    , p17_a1 JTF_NUMBER_TABLE
    , p17_a2 JTF_NUMBER_TABLE
    , p17_a3 JTF_VARCHAR2_TABLE_100
    , p17_a4 JTF_VARCHAR2_TABLE_100
    , p17_a5 JTF_VARCHAR2_TABLE_100
    , p_called_by_workflow  VARCHAR2
    , p_workflow_process_id  NUMBER
    , x_workflow_process_id out nocopy  NUMBER
    , x_interaction_id out nocopy  NUMBER
  )

  as
    ddp_last_update_date date;
    ddp_service_request_rec iem_servicerequest_pvt.service_request_rec_type;
    ddp_notes iem_servicerequest_pvt.notes_table;
    ddp_contacts iem_servicerequest_pvt.contacts_table;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any














    ddp_last_update_date := rosetta_g_miss_date_in_map(p_last_update_date);

    ddp_service_request_rec.request_date := rosetta_g_miss_date_in_map(p15_a0);
    ddp_service_request_rec.type_id := p15_a1;
    ddp_service_request_rec.type_name := p15_a2;
    ddp_service_request_rec.status_id := p15_a3;
    ddp_service_request_rec.status_name := p15_a4;
    ddp_service_request_rec.severity_id := p15_a5;
    ddp_service_request_rec.severity_name := p15_a6;
    ddp_service_request_rec.urgency_id := p15_a7;
    ddp_service_request_rec.urgency_name := p15_a8;
    ddp_service_request_rec.closed_date := rosetta_g_miss_date_in_map(p15_a9);
    ddp_service_request_rec.owner_id := p15_a10;
    ddp_service_request_rec.owner_group_id := p15_a11;
    ddp_service_request_rec.publish_flag := p15_a12;
    ddp_service_request_rec.summary := p15_a13;
    ddp_service_request_rec.caller_type := p15_a14;
    ddp_service_request_rec.customer_id := p15_a15;
    ddp_service_request_rec.customer_number := p15_a16;
    ddp_service_request_rec.employee_id := p15_a17;
    ddp_service_request_rec.employee_number := p15_a18;
    ddp_service_request_rec.verify_cp_flag := p15_a19;
    ddp_service_request_rec.customer_product_id := p15_a20;
    ddp_service_request_rec.platform_id := p15_a21;
    ddp_service_request_rec.platform_version := p15_a22;
    ddp_service_request_rec.db_version := p15_a23;
    ddp_service_request_rec.platform_version_id := p15_a24;
    ddp_service_request_rec.cp_component_id := p15_a25;
    ddp_service_request_rec.cp_component_version_id := p15_a26;
    ddp_service_request_rec.cp_subcomponent_id := p15_a27;
    ddp_service_request_rec.cp_subcomponent_version_id := p15_a28;
    ddp_service_request_rec.language_id := p15_a29;
    ddp_service_request_rec.language := p15_a30;
    ddp_service_request_rec.cp_ref_number := p15_a31;
    ddp_service_request_rec.inventory_item_id := p15_a32;
    ddp_service_request_rec.inventory_item_conc_segs := p15_a33;
    ddp_service_request_rec.inventory_item_segment1 := p15_a34;
    ddp_service_request_rec.inventory_item_segment2 := p15_a35;
    ddp_service_request_rec.inventory_item_segment3 := p15_a36;
    ddp_service_request_rec.inventory_item_segment4 := p15_a37;
    ddp_service_request_rec.inventory_item_segment5 := p15_a38;
    ddp_service_request_rec.inventory_item_segment6 := p15_a39;
    ddp_service_request_rec.inventory_item_segment7 := p15_a40;
    ddp_service_request_rec.inventory_item_segment8 := p15_a41;
    ddp_service_request_rec.inventory_item_segment9 := p15_a42;
    ddp_service_request_rec.inventory_item_segment10 := p15_a43;
    ddp_service_request_rec.inventory_item_segment11 := p15_a44;
    ddp_service_request_rec.inventory_item_segment12 := p15_a45;
    ddp_service_request_rec.inventory_item_segment13 := p15_a46;
    ddp_service_request_rec.inventory_item_segment14 := p15_a47;
    ddp_service_request_rec.inventory_item_segment15 := p15_a48;
    ddp_service_request_rec.inventory_item_segment16 := p15_a49;
    ddp_service_request_rec.inventory_item_segment17 := p15_a50;
    ddp_service_request_rec.inventory_item_segment18 := p15_a51;
    ddp_service_request_rec.inventory_item_segment19 := p15_a52;
    ddp_service_request_rec.inventory_item_segment20 := p15_a53;
    ddp_service_request_rec.inventory_item_vals_or_ids := p15_a54;
    ddp_service_request_rec.inventory_org_id := p15_a55;
    ddp_service_request_rec.current_serial_number := p15_a56;
    ddp_service_request_rec.original_order_number := p15_a57;
    ddp_service_request_rec.purchase_order_num := p15_a58;
    ddp_service_request_rec.problem_code := p15_a59;
    ddp_service_request_rec.exp_resolution_date := rosetta_g_miss_date_in_map(p15_a60);
    ddp_service_request_rec.install_site_use_id := p15_a61;
    ddp_service_request_rec.request_attribute_1 := p15_a62;
    ddp_service_request_rec.request_attribute_2 := p15_a63;
    ddp_service_request_rec.request_attribute_3 := p15_a64;
    ddp_service_request_rec.request_attribute_4 := p15_a65;
    ddp_service_request_rec.request_attribute_5 := p15_a66;
    ddp_service_request_rec.request_attribute_6 := p15_a67;
    ddp_service_request_rec.request_attribute_7 := p15_a68;
    ddp_service_request_rec.request_attribute_8 := p15_a69;
    ddp_service_request_rec.request_attribute_9 := p15_a70;
    ddp_service_request_rec.request_attribute_10 := p15_a71;
    ddp_service_request_rec.request_attribute_11 := p15_a72;
    ddp_service_request_rec.request_attribute_12 := p15_a73;
    ddp_service_request_rec.request_attribute_13 := p15_a74;
    ddp_service_request_rec.request_attribute_14 := p15_a75;
    ddp_service_request_rec.request_attribute_15 := p15_a76;
    ddp_service_request_rec.request_context := p15_a77;
    ddp_service_request_rec.bill_to_site_use_id := p15_a78;
    ddp_service_request_rec.bill_to_contact_id := p15_a79;
    ddp_service_request_rec.ship_to_site_use_id := p15_a80;
    ddp_service_request_rec.ship_to_contact_id := p15_a81;
    ddp_service_request_rec.resolution_code := p15_a82;
    ddp_service_request_rec.act_resolution_date := rosetta_g_miss_date_in_map(p15_a83);
    ddp_service_request_rec.public_comment_flag := p15_a84;
    ddp_service_request_rec.parent_interaction_id := p15_a85;
    ddp_service_request_rec.contract_service_id := p15_a86;
    ddp_service_request_rec.contract_service_number := p15_a87;
    ddp_service_request_rec.contract_id := p15_a88;
    ddp_service_request_rec.project_number := p15_a89;
    ddp_service_request_rec.qa_collection_plan_id := p15_a90;
    ddp_service_request_rec.account_id := p15_a91;
    ddp_service_request_rec.resource_type := p15_a92;
    ddp_service_request_rec.resource_subtype_id := p15_a93;
    ddp_service_request_rec.cust_po_number := p15_a94;
    ddp_service_request_rec.cust_ticket_number := p15_a95;
    ddp_service_request_rec.sr_creation_channel := p15_a96;
    ddp_service_request_rec.obligation_date := rosetta_g_miss_date_in_map(p15_a97);
    ddp_service_request_rec.time_zone_id := p15_a98;
    ddp_service_request_rec.time_difference := p15_a99;
    ddp_service_request_rec.site_id := p15_a100;
    ddp_service_request_rec.customer_site_id := p15_a101;
    ddp_service_request_rec.territory_id := p15_a102;
    ddp_service_request_rec.initialize_flag := p15_a103;
    ddp_service_request_rec.cp_revision_id := p15_a104;
    ddp_service_request_rec.inv_item_revision := p15_a105;
    ddp_service_request_rec.inv_component_id := p15_a106;
    ddp_service_request_rec.inv_component_version := p15_a107;
    ddp_service_request_rec.inv_subcomponent_id := p15_a108;
    ddp_service_request_rec.inv_subcomponent_version := p15_a109;
    ddp_service_request_rec.tier := p15_a110;
    ddp_service_request_rec.tier_version := p15_a111;
    ddp_service_request_rec.operating_system := p15_a112;
    ddp_service_request_rec.operating_system_version := p15_a113;
    ddp_service_request_rec.database := p15_a114;
    ddp_service_request_rec.cust_pref_lang_id := p15_a115;
    ddp_service_request_rec.category_id := p15_a116;
    ddp_service_request_rec.group_type := p15_a117;
    ddp_service_request_rec.group_territory_id := p15_a118;
    ddp_service_request_rec.inv_platform_org_id := p15_a119;
    ddp_service_request_rec.component_version := p15_a120;
    ddp_service_request_rec.subcomponent_version := p15_a121;
    ddp_service_request_rec.product_revision := p15_a122;
    ddp_service_request_rec.comm_pref_code := p15_a123;
    ddp_service_request_rec.cust_pref_lang_code := p15_a124;
    ddp_service_request_rec.last_update_channel := p15_a125;

    iem_servicerequest_pvt_w.rosetta_table_copy_in_p4(ddp_notes, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      );

    iem_servicerequest_pvt_w.rosetta_table_copy_in_p6(ddp_contacts, p17_a0
      , p17_a1
      , p17_a2
      , p17_a3
      , p17_a4
      , p17_a5
      );





    -- here's the delegated call to the old PL/SQL routine
    iem_servicerequest_pvt.update_servicerequest_wrap(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_request_id,
      p_request_number,
      p_audit_comments,
      p_object_version_number,
      p_resp_appl_id,
      p_resp_id,
      p_last_updated_by,
      p_last_update_login,
      ddp_last_update_date,
      ddp_service_request_rec,
      ddp_notes,
      ddp_contacts,
      p_called_by_workflow,
      p_workflow_process_id,
      x_workflow_process_id,
      x_interaction_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





















  end;

  procedure initialize_rec(p0_a0 in out nocopy  DATE
    , p0_a1 in out nocopy  NUMBER
    , p0_a2 in out nocopy  VARCHAR2
    , p0_a3 in out nocopy  NUMBER
    , p0_a4 in out nocopy  VARCHAR2
    , p0_a5 in out nocopy  NUMBER
    , p0_a6 in out nocopy  VARCHAR2
    , p0_a7 in out nocopy  NUMBER
    , p0_a8 in out nocopy  VARCHAR2
    , p0_a9 in out nocopy  DATE
    , p0_a10 in out nocopy  NUMBER
    , p0_a11 in out nocopy  NUMBER
    , p0_a12 in out nocopy  VARCHAR2
    , p0_a13 in out nocopy  VARCHAR2
    , p0_a14 in out nocopy  VARCHAR2
    , p0_a15 in out nocopy  NUMBER
    , p0_a16 in out nocopy  VARCHAR2
    , p0_a17 in out nocopy  NUMBER
    , p0_a18 in out nocopy  VARCHAR2
    , p0_a19 in out nocopy  VARCHAR2
    , p0_a20 in out nocopy  NUMBER
    , p0_a21 in out nocopy  NUMBER
    , p0_a22 in out nocopy  VARCHAR2
    , p0_a23 in out nocopy  VARCHAR2
    , p0_a24 in out nocopy  NUMBER
    , p0_a25 in out nocopy  NUMBER
    , p0_a26 in out nocopy  NUMBER
    , p0_a27 in out nocopy  NUMBER
    , p0_a28 in out nocopy  NUMBER
    , p0_a29 in out nocopy  NUMBER
    , p0_a30 in out nocopy  VARCHAR2
    , p0_a31 in out nocopy  NUMBER
    , p0_a32 in out nocopy  NUMBER
    , p0_a33 in out nocopy  VARCHAR2
    , p0_a34 in out nocopy  VARCHAR2
    , p0_a35 in out nocopy  VARCHAR2
    , p0_a36 in out nocopy  VARCHAR2
    , p0_a37 in out nocopy  VARCHAR2
    , p0_a38 in out nocopy  VARCHAR2
    , p0_a39 in out nocopy  VARCHAR2
    , p0_a40 in out nocopy  VARCHAR2
    , p0_a41 in out nocopy  VARCHAR2
    , p0_a42 in out nocopy  VARCHAR2
    , p0_a43 in out nocopy  VARCHAR2
    , p0_a44 in out nocopy  VARCHAR2
    , p0_a45 in out nocopy  VARCHAR2
    , p0_a46 in out nocopy  VARCHAR2
    , p0_a47 in out nocopy  VARCHAR2
    , p0_a48 in out nocopy  VARCHAR2
    , p0_a49 in out nocopy  VARCHAR2
    , p0_a50 in out nocopy  VARCHAR2
    , p0_a51 in out nocopy  VARCHAR2
    , p0_a52 in out nocopy  VARCHAR2
    , p0_a53 in out nocopy  VARCHAR2
    , p0_a54 in out nocopy  VARCHAR2
    , p0_a55 in out nocopy  NUMBER
    , p0_a56 in out nocopy  VARCHAR2
    , p0_a57 in out nocopy  NUMBER
    , p0_a58 in out nocopy  VARCHAR2
    , p0_a59 in out nocopy  VARCHAR2
    , p0_a60 in out nocopy  DATE
    , p0_a61 in out nocopy  NUMBER
    , p0_a62 in out nocopy  VARCHAR2
    , p0_a63 in out nocopy  VARCHAR2
    , p0_a64 in out nocopy  VARCHAR2
    , p0_a65 in out nocopy  VARCHAR2
    , p0_a66 in out nocopy  VARCHAR2
    , p0_a67 in out nocopy  VARCHAR2
    , p0_a68 in out nocopy  VARCHAR2
    , p0_a69 in out nocopy  VARCHAR2
    , p0_a70 in out nocopy  VARCHAR2
    , p0_a71 in out nocopy  VARCHAR2
    , p0_a72 in out nocopy  VARCHAR2
    , p0_a73 in out nocopy  VARCHAR2
    , p0_a74 in out nocopy  VARCHAR2
    , p0_a75 in out nocopy  VARCHAR2
    , p0_a76 in out nocopy  VARCHAR2
    , p0_a77 in out nocopy  VARCHAR2
    , p0_a78 in out nocopy  NUMBER
    , p0_a79 in out nocopy  NUMBER
    , p0_a80 in out nocopy  NUMBER
    , p0_a81 in out nocopy  NUMBER
    , p0_a82 in out nocopy  VARCHAR2
    , p0_a83 in out nocopy  DATE
    , p0_a84 in out nocopy  VARCHAR2
    , p0_a85 in out nocopy  NUMBER
    , p0_a86 in out nocopy  NUMBER
    , p0_a87 in out nocopy  VARCHAR2
    , p0_a88 in out nocopy  NUMBER
    , p0_a89 in out nocopy  VARCHAR2
    , p0_a90 in out nocopy  NUMBER
    , p0_a91 in out nocopy  NUMBER
    , p0_a92 in out nocopy  VARCHAR2
    , p0_a93 in out nocopy  NUMBER
    , p0_a94 in out nocopy  VARCHAR2
    , p0_a95 in out nocopy  VARCHAR2
    , p0_a96 in out nocopy  VARCHAR2
    , p0_a97 in out nocopy  DATE
    , p0_a98 in out nocopy  NUMBER
    , p0_a99 in out nocopy  NUMBER
    , p0_a100 in out nocopy  NUMBER
    , p0_a101 in out nocopy  NUMBER
    , p0_a102 in out nocopy  NUMBER
    , p0_a103 in out nocopy  VARCHAR2
    , p0_a104 in out nocopy  NUMBER
    , p0_a105 in out nocopy  VARCHAR2
    , p0_a106 in out nocopy  NUMBER
    , p0_a107 in out nocopy  VARCHAR2
    , p0_a108 in out nocopy  NUMBER
    , p0_a109 in out nocopy  VARCHAR2
    , p0_a110 in out nocopy  VARCHAR2
    , p0_a111 in out nocopy  VARCHAR2
    , p0_a112 in out nocopy  VARCHAR2
    , p0_a113 in out nocopy  VARCHAR2
    , p0_a114 in out nocopy  VARCHAR2
    , p0_a115 in out nocopy  NUMBER
    , p0_a116 in out nocopy  NUMBER
    , p0_a117 in out nocopy  VARCHAR2
    , p0_a118 in out nocopy  NUMBER
    , p0_a119 in out nocopy  NUMBER
    , p0_a120 in out nocopy  VARCHAR2
    , p0_a121 in out nocopy  VARCHAR2
    , p0_a122 in out nocopy  VARCHAR2
    , p0_a123 in out nocopy  VARCHAR2
    , p0_a124 in out nocopy  VARCHAR2
    , p0_a125 in out nocopy  VARCHAR2
  )

  as
    ddp_sr_record iem_servicerequest_pvt.service_request_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_sr_record.request_date := rosetta_g_miss_date_in_map(p0_a0);
    ddp_sr_record.type_id := p0_a1;
    ddp_sr_record.type_name := p0_a2;
    ddp_sr_record.status_id := p0_a3;
    ddp_sr_record.status_name := p0_a4;
    ddp_sr_record.severity_id := p0_a5;
    ddp_sr_record.severity_name := p0_a6;
    ddp_sr_record.urgency_id := p0_a7;
    ddp_sr_record.urgency_name := p0_a8;
    ddp_sr_record.closed_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_sr_record.owner_id := p0_a10;
    ddp_sr_record.owner_group_id := p0_a11;
    ddp_sr_record.publish_flag := p0_a12;
    ddp_sr_record.summary := p0_a13;
    ddp_sr_record.caller_type := p0_a14;
    ddp_sr_record.customer_id := p0_a15;
    ddp_sr_record.customer_number := p0_a16;
    ddp_sr_record.employee_id := p0_a17;
    ddp_sr_record.employee_number := p0_a18;
    ddp_sr_record.verify_cp_flag := p0_a19;
    ddp_sr_record.customer_product_id := p0_a20;
    ddp_sr_record.platform_id := p0_a21;
    ddp_sr_record.platform_version := p0_a22;
    ddp_sr_record.db_version := p0_a23;
    ddp_sr_record.platform_version_id := p0_a24;
    ddp_sr_record.cp_component_id := p0_a25;
    ddp_sr_record.cp_component_version_id := p0_a26;
    ddp_sr_record.cp_subcomponent_id := p0_a27;
    ddp_sr_record.cp_subcomponent_version_id := p0_a28;
    ddp_sr_record.language_id := p0_a29;
    ddp_sr_record.language := p0_a30;
    ddp_sr_record.cp_ref_number := p0_a31;
    ddp_sr_record.inventory_item_id := p0_a32;
    ddp_sr_record.inventory_item_conc_segs := p0_a33;
    ddp_sr_record.inventory_item_segment1 := p0_a34;
    ddp_sr_record.inventory_item_segment2 := p0_a35;
    ddp_sr_record.inventory_item_segment3 := p0_a36;
    ddp_sr_record.inventory_item_segment4 := p0_a37;
    ddp_sr_record.inventory_item_segment5 := p0_a38;
    ddp_sr_record.inventory_item_segment6 := p0_a39;
    ddp_sr_record.inventory_item_segment7 := p0_a40;
    ddp_sr_record.inventory_item_segment8 := p0_a41;
    ddp_sr_record.inventory_item_segment9 := p0_a42;
    ddp_sr_record.inventory_item_segment10 := p0_a43;
    ddp_sr_record.inventory_item_segment11 := p0_a44;
    ddp_sr_record.inventory_item_segment12 := p0_a45;
    ddp_sr_record.inventory_item_segment13 := p0_a46;
    ddp_sr_record.inventory_item_segment14 := p0_a47;
    ddp_sr_record.inventory_item_segment15 := p0_a48;
    ddp_sr_record.inventory_item_segment16 := p0_a49;
    ddp_sr_record.inventory_item_segment17 := p0_a50;
    ddp_sr_record.inventory_item_segment18 := p0_a51;
    ddp_sr_record.inventory_item_segment19 := p0_a52;
    ddp_sr_record.inventory_item_segment20 := p0_a53;
    ddp_sr_record.inventory_item_vals_or_ids := p0_a54;
    ddp_sr_record.inventory_org_id := p0_a55;
    ddp_sr_record.current_serial_number := p0_a56;
    ddp_sr_record.original_order_number := p0_a57;
    ddp_sr_record.purchase_order_num := p0_a58;
    ddp_sr_record.problem_code := p0_a59;
    ddp_sr_record.exp_resolution_date := rosetta_g_miss_date_in_map(p0_a60);
    ddp_sr_record.install_site_use_id := p0_a61;
    ddp_sr_record.request_attribute_1 := p0_a62;
    ddp_sr_record.request_attribute_2 := p0_a63;
    ddp_sr_record.request_attribute_3 := p0_a64;
    ddp_sr_record.request_attribute_4 := p0_a65;
    ddp_sr_record.request_attribute_5 := p0_a66;
    ddp_sr_record.request_attribute_6 := p0_a67;
    ddp_sr_record.request_attribute_7 := p0_a68;
    ddp_sr_record.request_attribute_8 := p0_a69;
    ddp_sr_record.request_attribute_9 := p0_a70;
    ddp_sr_record.request_attribute_10 := p0_a71;
    ddp_sr_record.request_attribute_11 := p0_a72;
    ddp_sr_record.request_attribute_12 := p0_a73;
    ddp_sr_record.request_attribute_13 := p0_a74;
    ddp_sr_record.request_attribute_14 := p0_a75;
    ddp_sr_record.request_attribute_15 := p0_a76;
    ddp_sr_record.request_context := p0_a77;
    ddp_sr_record.bill_to_site_use_id := p0_a78;
    ddp_sr_record.bill_to_contact_id := p0_a79;
    ddp_sr_record.ship_to_site_use_id := p0_a80;
    ddp_sr_record.ship_to_contact_id := p0_a81;
    ddp_sr_record.resolution_code := p0_a82;
    ddp_sr_record.act_resolution_date := rosetta_g_miss_date_in_map(p0_a83);
    ddp_sr_record.public_comment_flag := p0_a84;
    ddp_sr_record.parent_interaction_id := p0_a85;
    ddp_sr_record.contract_service_id := p0_a86;
    ddp_sr_record.contract_service_number := p0_a87;
    ddp_sr_record.contract_id := p0_a88;
    ddp_sr_record.project_number := p0_a89;
    ddp_sr_record.qa_collection_plan_id := p0_a90;
    ddp_sr_record.account_id := p0_a91;
    ddp_sr_record.resource_type := p0_a92;
    ddp_sr_record.resource_subtype_id := p0_a93;
    ddp_sr_record.cust_po_number := p0_a94;
    ddp_sr_record.cust_ticket_number := p0_a95;
    ddp_sr_record.sr_creation_channel := p0_a96;
    ddp_sr_record.obligation_date := rosetta_g_miss_date_in_map(p0_a97);
    ddp_sr_record.time_zone_id := p0_a98;
    ddp_sr_record.time_difference := p0_a99;
    ddp_sr_record.site_id := p0_a100;
    ddp_sr_record.customer_site_id := p0_a101;
    ddp_sr_record.territory_id := p0_a102;
    ddp_sr_record.initialize_flag := p0_a103;
    ddp_sr_record.cp_revision_id := p0_a104;
    ddp_sr_record.inv_item_revision := p0_a105;
    ddp_sr_record.inv_component_id := p0_a106;
    ddp_sr_record.inv_component_version := p0_a107;
    ddp_sr_record.inv_subcomponent_id := p0_a108;
    ddp_sr_record.inv_subcomponent_version := p0_a109;
    ddp_sr_record.tier := p0_a110;
    ddp_sr_record.tier_version := p0_a111;
    ddp_sr_record.operating_system := p0_a112;
    ddp_sr_record.operating_system_version := p0_a113;
    ddp_sr_record.database := p0_a114;
    ddp_sr_record.cust_pref_lang_id := p0_a115;
    ddp_sr_record.category_id := p0_a116;
    ddp_sr_record.group_type := p0_a117;
    ddp_sr_record.group_territory_id := p0_a118;
    ddp_sr_record.inv_platform_org_id := p0_a119;
    ddp_sr_record.component_version := p0_a120;
    ddp_sr_record.subcomponent_version := p0_a121;
    ddp_sr_record.product_revision := p0_a122;
    ddp_sr_record.comm_pref_code := p0_a123;
    ddp_sr_record.cust_pref_lang_code := p0_a124;
    ddp_sr_record.last_update_channel := p0_a125;

    -- here's the delegated call to the old PL/SQL routine
    iem_servicerequest_pvt.initialize_rec(ddp_sr_record);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddp_sr_record.request_date;
    p0_a1 := ddp_sr_record.type_id;
    p0_a2 := ddp_sr_record.type_name;
    p0_a3 := ddp_sr_record.status_id;
    p0_a4 := ddp_sr_record.status_name;
    p0_a5 := ddp_sr_record.severity_id;
    p0_a6 := ddp_sr_record.severity_name;
    p0_a7 := ddp_sr_record.urgency_id;
    p0_a8 := ddp_sr_record.urgency_name;
    p0_a9 := ddp_sr_record.closed_date;
    p0_a10 := ddp_sr_record.owner_id;
    p0_a11 := ddp_sr_record.owner_group_id;
    p0_a12 := ddp_sr_record.publish_flag;
    p0_a13 := ddp_sr_record.summary;
    p0_a14 := ddp_sr_record.caller_type;
    p0_a15 := ddp_sr_record.customer_id;
    p0_a16 := ddp_sr_record.customer_number;
    p0_a17 := ddp_sr_record.employee_id;
    p0_a18 := ddp_sr_record.employee_number;
    p0_a19 := ddp_sr_record.verify_cp_flag;
    p0_a20 := ddp_sr_record.customer_product_id;
    p0_a21 := ddp_sr_record.platform_id;
    p0_a22 := ddp_sr_record.platform_version;
    p0_a23 := ddp_sr_record.db_version;
    p0_a24 := ddp_sr_record.platform_version_id;
    p0_a25 := ddp_sr_record.cp_component_id;
    p0_a26 := ddp_sr_record.cp_component_version_id;
    p0_a27 := ddp_sr_record.cp_subcomponent_id;
    p0_a28 := ddp_sr_record.cp_subcomponent_version_id;
    p0_a29 := ddp_sr_record.language_id;
    p0_a30 := ddp_sr_record.language;
    p0_a31 := ddp_sr_record.cp_ref_number;
    p0_a32 := ddp_sr_record.inventory_item_id;
    p0_a33 := ddp_sr_record.inventory_item_conc_segs;
    p0_a34 := ddp_sr_record.inventory_item_segment1;
    p0_a35 := ddp_sr_record.inventory_item_segment2;
    p0_a36 := ddp_sr_record.inventory_item_segment3;
    p0_a37 := ddp_sr_record.inventory_item_segment4;
    p0_a38 := ddp_sr_record.inventory_item_segment5;
    p0_a39 := ddp_sr_record.inventory_item_segment6;
    p0_a40 := ddp_sr_record.inventory_item_segment7;
    p0_a41 := ddp_sr_record.inventory_item_segment8;
    p0_a42 := ddp_sr_record.inventory_item_segment9;
    p0_a43 := ddp_sr_record.inventory_item_segment10;
    p0_a44 := ddp_sr_record.inventory_item_segment11;
    p0_a45 := ddp_sr_record.inventory_item_segment12;
    p0_a46 := ddp_sr_record.inventory_item_segment13;
    p0_a47 := ddp_sr_record.inventory_item_segment14;
    p0_a48 := ddp_sr_record.inventory_item_segment15;
    p0_a49 := ddp_sr_record.inventory_item_segment16;
    p0_a50 := ddp_sr_record.inventory_item_segment17;
    p0_a51 := ddp_sr_record.inventory_item_segment18;
    p0_a52 := ddp_sr_record.inventory_item_segment19;
    p0_a53 := ddp_sr_record.inventory_item_segment20;
    p0_a54 := ddp_sr_record.inventory_item_vals_or_ids;
    p0_a55 := ddp_sr_record.inventory_org_id;
    p0_a56 := ddp_sr_record.current_serial_number;
    p0_a57 := ddp_sr_record.original_order_number;
    p0_a58 := ddp_sr_record.purchase_order_num;
    p0_a59 := ddp_sr_record.problem_code;
    p0_a60 := ddp_sr_record.exp_resolution_date;
    p0_a61 := ddp_sr_record.install_site_use_id;
    p0_a62 := ddp_sr_record.request_attribute_1;
    p0_a63 := ddp_sr_record.request_attribute_2;
    p0_a64 := ddp_sr_record.request_attribute_3;
    p0_a65 := ddp_sr_record.request_attribute_4;
    p0_a66 := ddp_sr_record.request_attribute_5;
    p0_a67 := ddp_sr_record.request_attribute_6;
    p0_a68 := ddp_sr_record.request_attribute_7;
    p0_a69 := ddp_sr_record.request_attribute_8;
    p0_a70 := ddp_sr_record.request_attribute_9;
    p0_a71 := ddp_sr_record.request_attribute_10;
    p0_a72 := ddp_sr_record.request_attribute_11;
    p0_a73 := ddp_sr_record.request_attribute_12;
    p0_a74 := ddp_sr_record.request_attribute_13;
    p0_a75 := ddp_sr_record.request_attribute_14;
    p0_a76 := ddp_sr_record.request_attribute_15;
    p0_a77 := ddp_sr_record.request_context;
    p0_a78 := ddp_sr_record.bill_to_site_use_id;
    p0_a79 := ddp_sr_record.bill_to_contact_id;
    p0_a80 := ddp_sr_record.ship_to_site_use_id;
    p0_a81 := ddp_sr_record.ship_to_contact_id;
    p0_a82 := ddp_sr_record.resolution_code;
    p0_a83 := ddp_sr_record.act_resolution_date;
    p0_a84 := ddp_sr_record.public_comment_flag;
    p0_a85 := ddp_sr_record.parent_interaction_id;
    p0_a86 := ddp_sr_record.contract_service_id;
    p0_a87 := ddp_sr_record.contract_service_number;
    p0_a88 := ddp_sr_record.contract_id;
    p0_a89 := ddp_sr_record.project_number;
    p0_a90 := ddp_sr_record.qa_collection_plan_id;
    p0_a91 := ddp_sr_record.account_id;
    p0_a92 := ddp_sr_record.resource_type;
    p0_a93 := ddp_sr_record.resource_subtype_id;
    p0_a94 := ddp_sr_record.cust_po_number;
    p0_a95 := ddp_sr_record.cust_ticket_number;
    p0_a96 := ddp_sr_record.sr_creation_channel;
    p0_a97 := ddp_sr_record.obligation_date;
    p0_a98 := ddp_sr_record.time_zone_id;
    p0_a99 := ddp_sr_record.time_difference;
    p0_a100 := ddp_sr_record.site_id;
    p0_a101 := ddp_sr_record.customer_site_id;
    p0_a102 := ddp_sr_record.territory_id;
    p0_a103 := ddp_sr_record.initialize_flag;
    p0_a104 := ddp_sr_record.cp_revision_id;
    p0_a105 := ddp_sr_record.inv_item_revision;
    p0_a106 := ddp_sr_record.inv_component_id;
    p0_a107 := ddp_sr_record.inv_component_version;
    p0_a108 := ddp_sr_record.inv_subcomponent_id;
    p0_a109 := ddp_sr_record.inv_subcomponent_version;
    p0_a110 := ddp_sr_record.tier;
    p0_a111 := ddp_sr_record.tier_version;
    p0_a112 := ddp_sr_record.operating_system;
    p0_a113 := ddp_sr_record.operating_system_version;
    p0_a114 := ddp_sr_record.database;
    p0_a115 := ddp_sr_record.cust_pref_lang_id;
    p0_a116 := ddp_sr_record.category_id;
    p0_a117 := ddp_sr_record.group_type;
    p0_a118 := ddp_sr_record.group_territory_id;
    p0_a119 := ddp_sr_record.inv_platform_org_id;
    p0_a120 := ddp_sr_record.component_version;
    p0_a121 := ddp_sr_record.subcomponent_version;
    p0_a122 := ddp_sr_record.product_revision;
    p0_a123 := ddp_sr_record.comm_pref_code;
    p0_a124 := ddp_sr_record.cust_pref_lang_code;
    p0_a125 := ddp_sr_record.last_update_channel;
  end;

end iem_servicerequest_pvt_w;

/
