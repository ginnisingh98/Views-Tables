--------------------------------------------------------
--  DDL for Package Body PV_ASSIGN_UTIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ASSIGN_UTIL_PVT_W" as
  /* $Header: pvwautlb.pls 115.14 2002/12/26 16:05:06 vansub ship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy pv_assign_util_pvt.resource_details_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := pv_assign_util_pvt.resource_details_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := pv_assign_util_pvt.resource_details_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).notification_type := a0(indx);
          t(ddindx).decision_maker_flag := a1(indx);
          t(ddindx).user_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).person_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).person_type := a4(indx);
          t(ddindx).user_name := a5(indx);
          t(ddindx).resource_id := rosetta_g_miss_num_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t pv_assign_util_pvt.resource_details_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).notification_type;
          a1(indx) := t(ddindx).decision_maker_flag;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).user_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).person_id);
          a4(indx) := t(ddindx).person_type;
          a5(indx) := t(ddindx).user_name;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure create_party_notification(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  DATE := fnd_api.g_miss_date
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  NUMBER := 0-1962.0724
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  DATE := fnd_api.g_miss_date
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , x_party_notification_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out  nocopy VARCHAR2
  )
  as
    ddp_party_notify_rec pv_assign_util_pvt.party_notify_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_party_notify_rec.party_notification_id := rosetta_g_miss_num_map(p4_a0);
    ddp_party_notify_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_party_notify_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_party_notify_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_party_notify_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_party_notify_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_party_notify_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_party_notify_rec.request_id := rosetta_g_miss_num_map(p4_a7);
    ddp_party_notify_rec.program_application_id := rosetta_g_miss_num_map(p4_a8);
    ddp_party_notify_rec.program_id := rosetta_g_miss_num_map(p4_a9);
    ddp_party_notify_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a10);
    ddp_party_notify_rec.notification_id := rosetta_g_miss_num_map(p4_a11);
    ddp_party_notify_rec.notification_type := p4_a12;
    ddp_party_notify_rec.lead_assignment_id := rosetta_g_miss_num_map(p4_a13);
    ddp_party_notify_rec.wf_item_type := p4_a14;
    ddp_party_notify_rec.wf_item_key := p4_a15;
    ddp_party_notify_rec.user_id := rosetta_g_miss_num_map(p4_a16);
    ddp_party_notify_rec.user_name := p4_a17;
    ddp_party_notify_rec.resource_id := rosetta_g_miss_num_map(p4_a18);
    ddp_party_notify_rec.decision_maker_flag := p4_a19;
    ddp_party_notify_rec.resource_response := p4_a20;
    ddp_party_notify_rec.response_date := rosetta_g_miss_date_in_map(p4_a21);
    ddp_party_notify_rec.attribute_category := p4_a22;
    ddp_party_notify_rec.attribute1 := p4_a23;
    ddp_party_notify_rec.attribute2 := p4_a24;
    ddp_party_notify_rec.attribute3 := p4_a25;
    ddp_party_notify_rec.attribute4 := p4_a26;
    ddp_party_notify_rec.attribute5 := p4_a27;
    ddp_party_notify_rec.attribute6 := p4_a28;
    ddp_party_notify_rec.attribute7 := p4_a29;
    ddp_party_notify_rec.attribute8 := p4_a30;
    ddp_party_notify_rec.attribute9 := p4_a31;
    ddp_party_notify_rec.attribute10 := p4_a32;
    ddp_party_notify_rec.attribute11 := p4_a33;
    ddp_party_notify_rec.attribute12 := p4_a34;
    ddp_party_notify_rec.attribute13 := p4_a35;
    ddp_party_notify_rec.attribute14 := p4_a36;
    ddp_party_notify_rec.attribute15 := p4_a37;





    -- here's the delegated call to the old PL/SQL routine
    pv_assign_util_pvt.create_party_notification(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_party_notify_rec,
      x_party_notification_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure create_lead_workflow_row(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  DATE := fnd_api.g_miss_date
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , x_itemkey out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_workflow_rec pv_assign_util_pvt.lead_workflow_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_workflow_rec.lead_workflow_id := rosetta_g_miss_num_map(p4_a0);
    ddp_workflow_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_workflow_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_workflow_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_workflow_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_workflow_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_workflow_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_workflow_rec.entity := p4_a7;
    ddp_workflow_rec.lead_id := rosetta_g_miss_num_map(p4_a8);
    ddp_workflow_rec.wf_item_type := p4_a9;
    ddp_workflow_rec.wf_item_key := p4_a10;
    ddp_workflow_rec.wf_status := p4_a11;
    ddp_workflow_rec.matched_due_date := rosetta_g_miss_date_in_map(p4_a12);
    ddp_workflow_rec.offered_due_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_workflow_rec.bypass_cm_ok_flag := p4_a14;
    ddp_workflow_rec.latest_routing_flag := p4_a15;
    ddp_workflow_rec.routing_status := p4_a16;





    -- here's the delegated call to the old PL/SQL routine
    pv_assign_util_pvt.create_lead_workflow_row(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_workflow_rec,
      x_itemkey,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure create_lead_assignment_row(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , x_lead_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out  nocopy VARCHAR2
  )
  as
    ddp_assignment_rec pv_assign_util_pvt.assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_assignment_rec.lead_assignment_id := rosetta_g_miss_num_map(p4_a0);
    ddp_assignment_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_assignment_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_assignment_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_assignment_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_assignment_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_assignment_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_assignment_rec.lead_id := rosetta_g_miss_num_map(p4_a7);
    ddp_assignment_rec.partner_id := rosetta_g_miss_num_map(p4_a8);
    ddp_assignment_rec.partner_access_code := p4_a9;
    ddp_assignment_rec.related_party_id := rosetta_g_miss_num_map(p4_a10);
    ddp_assignment_rec.related_party_access_code := p4_a11;
    ddp_assignment_rec.assign_sequence := rosetta_g_miss_num_map(p4_a12);
    ddp_assignment_rec.status_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_assignment_rec.status := p4_a14;
    ddp_assignment_rec.reason_code := p4_a15;
    ddp_assignment_rec.source_type := p4_a16;
    ddp_assignment_rec.wf_item_type := p4_a17;
    ddp_assignment_rec.wf_item_key := p4_a18;
    ddp_assignment_rec.error_txt := p4_a19;





    -- here's the delegated call to the old PL/SQL routine
    pv_assign_util_pvt.create_lead_assignment_row(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_assignment_rec,
      x_lead_assignment_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure get_partner_info(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_mode  VARCHAR2
    , p_partner_id  NUMBER
    , p_entity  VARCHAR2
    , p_entity_id  NUMBER
    , p_retrieve_mode  VARCHAR2
    , p9_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_NUMBER_TABLE
    , p9_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , x_vad_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddx_rs_details_tbl pv_assign_util_pvt.resource_details_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    pv_assign_util_pvt_w.rosetta_table_copy_in_p4(ddx_rs_details_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      );





    -- here's the delegated call to the old PL/SQL routine
    pv_assign_util_pvt.get_partner_info(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_mode,
      p_partner_id,
      p_entity,
      p_entity_id,
      p_retrieve_mode,
      ddx_rs_details_tbl,
      x_vad_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any









    pv_assign_util_pvt_w.rosetta_table_copy_out_p4(ddx_rs_details_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      );




  end;

end pv_assign_util_pvt_w;

/
