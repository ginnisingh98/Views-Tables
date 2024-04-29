--------------------------------------------------------
--  DDL for Package Body PV_PG_NOTIF_UTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_NOTIF_UTILITY_PVT_W" as
  /* $Header: pvxwpnub.pls 115.8 2003/12/01 19:18:31 pukken ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p6(t out nocopy pv_pg_notif_utility_pvt.user_notify_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).user_id := a0(indx);
          t(ddindx).user_name := a1(indx);
          t(ddindx).user_resource_id := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t pv_pg_notif_utility_pvt.user_notify_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_400();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_400();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).user_id;
          a1(indx) := t(ddindx).user_name;
          a2(indx) := t(ddindx).user_resource_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure get_users_list(p_partner_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , x_user_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddx_user_notify_rec_tbl pv_pg_notif_utility_pvt.user_notify_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    pv_pg_notif_utility_pvt.get_users_list(p_partner_id,
      ddx_user_notify_rec_tbl,
      x_user_count,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    pv_pg_notif_utility_pvt_w.rosetta_table_copy_out_p6(ddx_user_notify_rec_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


  end;

  procedure set_pgp_notif(p_notif_id  NUMBER
    , p_object_version  NUMBER
    , p_partner_id  NUMBER
    , p_user_id  NUMBER
    , p_arc_notif_for_entity_code  VARCHAR2
    , p_notif_for_entity_id  NUMBER
    , p_notif_type_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  NUMBER
    , p8_a3 out nocopy  NUMBER
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  DATE
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  DATE
    , p8_a12 out nocopy  NUMBER
  )

  as
    ddx_pgp_notif_rec pv_ge_party_notif_pvt.pgp_notif_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    pv_pg_notif_utility_pvt.set_pgp_notif(p_notif_id,
      p_object_version,
      p_partner_id,
      p_user_id,
      p_arc_notif_for_entity_code,
      p_notif_for_entity_id,
      p_notif_type_code,
      x_return_status,
      ddx_pgp_notif_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := ddx_pgp_notif_rec.party_notification_id;
    p8_a1 := ddx_pgp_notif_rec.notification_id;
    p8_a2 := ddx_pgp_notif_rec.object_version_number;
    p8_a3 := ddx_pgp_notif_rec.partner_id;
    p8_a4 := ddx_pgp_notif_rec.recipient_user_id;
    p8_a5 := ddx_pgp_notif_rec.notif_for_entity_id;
    p8_a6 := ddx_pgp_notif_rec.arc_notif_for_entity_code;
    p8_a7 := ddx_pgp_notif_rec.notif_type_code;
    p8_a8 := ddx_pgp_notif_rec.created_by;
    p8_a9 := ddx_pgp_notif_rec.creation_date;
    p8_a10 := ddx_pgp_notif_rec.last_updated_by;
    p8_a11 := ddx_pgp_notif_rec.last_update_date;
    p8_a12 := ddx_pgp_notif_rec.last_update_login;
  end;

  procedure send_mbrship_chng_notif(p_api_version  NUMBER
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
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
  )

  as
    ddp_mbrship_chng_rec pv_pg_notif_utility_pvt.mbrship_chng_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_mbrship_chng_rec.id := p7_a0;
    ddp_mbrship_chng_rec.partner_id := p7_a1;
    ddp_mbrship_chng_rec.resource_id := p7_a2;
    ddp_mbrship_chng_rec.notif_type := p7_a3;
    ddp_mbrship_chng_rec.message_subj := p7_a4;
    ddp_mbrship_chng_rec.message_body := p7_a5;

    -- here's the delegated call to the old PL/SQL routine
    pv_pg_notif_utility_pvt.send_mbrship_chng_notif(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_mbrship_chng_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure send_invitations(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_partner_id  NUMBER
    , p_invite_header_id  NUMBER
    , p_from_program_id  NUMBER
    , p_notif_event_code  VARCHAR2
    , p_discount_value  VARCHAR2
    , p_discount_unit  VARCHAR2
    , p_currency  VARCHAR2
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);




    -- here's the delegated call to the old PL/SQL routine
    pv_pg_notif_utility_pvt.send_invitations(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_partner_id,
      p_invite_header_id,
      p_from_program_id,
      p_notif_event_code,
      p_discount_value,
      p_discount_unit,
      p_currency,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end pv_pg_notif_utility_pvt_w;

/
