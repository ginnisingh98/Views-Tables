--------------------------------------------------------
--  DDL for Package Body AMS_SCR_LEAD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCR_LEAD_PVT_W" as
  /* $Header: amswsldb.pls 115.0 2002/12/26 01:27:49 sodixit noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_sales_lead(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_party_type  VARCHAR2
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  NUMBER
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  NUMBER
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p_camp_sch_source_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_party_id  NUMBER
    , p_org_party_id  NUMBER
    , p_org_rel_party_id  NUMBER
  )

  as
    ddp_scr_lead_rec ams_scr_lead_pvt.scr_lead_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_scr_lead_rec.party_id := p4_a0;
    ddp_scr_lead_rec.first_name := p4_a1;
    ddp_scr_lead_rec.last_name := p4_a2;
    ddp_scr_lead_rec.organization := p4_a3;
    ddp_scr_lead_rec.job_title := p4_a4;
    ddp_scr_lead_rec.email_address := p4_a5;
    ddp_scr_lead_rec.day_area_code := p4_a6;
    ddp_scr_lead_rec.day_phone_number := p4_a7;
    ddp_scr_lead_rec.day_extension := p4_a8;
    ddp_scr_lead_rec.address1 := p4_a9;
    ddp_scr_lead_rec.address2 := p4_a10;
    ddp_scr_lead_rec.address3 := p4_a11;
    ddp_scr_lead_rec.address4 := p4_a12;
    ddp_scr_lead_rec.city := p4_a13;
    ddp_scr_lead_rec.state := p4_a14;
    ddp_scr_lead_rec.country := p4_a15;
    ddp_scr_lead_rec.postal_code := p4_a16;
    ddp_scr_lead_rec.interest_type := p4_a17;
    ddp_scr_lead_rec.purchasing_time_frame := p4_a18;
    ddp_scr_lead_rec.budget_status_code := p4_a19;
    ddp_scr_lead_rec.budget_amount := p4_a20;
    ddp_scr_lead_rec.budget_currency_code := p4_a21;
    ddp_scr_lead_rec.contact_role_code := p4_a22;








    -- here's the delegated call to the old PL/SQL routine
    ams_scr_lead_pvt.create_sales_lead(p_init_msg_list,
      p_commit,
      p_validation_level,
      p_party_type,
      ddp_scr_lead_rec,
      p_camp_sch_source_code,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_party_id,
      p_org_party_id,
      p_org_rel_party_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end ams_scr_lead_pvt_w;

/
