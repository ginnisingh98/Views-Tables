--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_REFERRAL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_REFERRAL_W" as
  /* $Header: asxwlrpb.pls 120.1 2005/06/23 15:52:01 appldev ship $ */
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

  procedure rosetta_table_copy_in_p53(t OUT NOCOPY  as_sales_lead_referral.t_overriding_usernames, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p53;
  procedure rosetta_table_copy_out_p53(t as_sales_lead_referral.t_overriding_usernames, a0 OUT NOCOPY  JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p53;

  procedure notify_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_lead_id  NUMBER
    , p_lead_status  VARCHAR2
    , p_salesforce_id  NUMBER
    , p_overriding_usernames JTF_VARCHAR2_TABLE_100
    , x_msg_count OUT NOCOPY   NUMBER
    , x_msg_data OUT NOCOPY   VARCHAR2
    , x_return_status OUT NOCOPY   VARCHAR2
  )

  as
    ddp_overriding_usernames as_sales_lead_referral.t_overriding_usernames;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    as_sales_lead_referral_w.rosetta_table_copy_in_p53(ddp_overriding_usernames, p_overriding_usernames);




    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_referral.notify_party(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_lead_id,
      p_lead_status,
      p_salesforce_id,
      ddp_overriding_usernames,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT NOCOPY  or IN-OUT args, if any










  end;

  procedure update_sales_referral_lead(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_check_access_flag  VARCHAR2
    , p_admin_flag  VARCHAR2
    , p_admin_group_id  NUMBER
    , p_identity_salesforce_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p_overriding_usernames JTF_VARCHAR2_TABLE_100
    , x_return_status OUT NOCOPY   VARCHAR2
    , x_msg_count OUT NOCOPY   NUMBER
    , x_msg_data OUT NOCOPY   VARCHAR2
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
  )

  as
    ddp_sales_lead_profile_tbl as_utility_pub.profile_tbl_type;
    ddp_sales_lead_rec as_sales_leads_pub.sales_lead_rec_type;
    ddp_overriding_usernames as_sales_lead_referral.t_overriding_usernames;
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

    as_sales_lead_referral_w.rosetta_table_copy_in_p53(ddp_overriding_usernames, p_overriding_usernames);




    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_referral.update_sales_referral_lead(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_check_access_flag,
      p_admin_flag,
      p_admin_group_id,
      p_identity_salesforce_id,
      ddp_sales_lead_profile_tbl,
      ddp_sales_lead_rec,
      ddp_overriding_usernames,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT NOCOPY  or IN-OUT args, if any













  end;

end as_sales_lead_referral_w;

/
