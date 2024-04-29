--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ACCNT_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ACCNT_MGMT_PVT_W" as
  /* $Header: pvxwpamb.pls 120.1 2005/09/08 13:14 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_party_site(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  NUMBER
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  DATE
    , p3_a18  DATE
    , p3_a19  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_party_site_id out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_party_site_rec pv_partner_accnt_mgmt_pvt.party_site_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_party_site_rec.party_site_use_id := p3_a0;
    ddp_party_site_rec.party_site_id := p3_a1;
    ddp_party_site_rec.party_id := p3_a2;
    ddp_party_site_rec.party_site_use_type := p3_a3;
    ddp_party_site_rec.primary_flag := p3_a4;
    ddp_party_site_rec.location.location_id := p3_a5;
    ddp_party_site_rec.location.address1 := p3_a6;
    ddp_party_site_rec.location.address2 := p3_a7;
    ddp_party_site_rec.location.address3 := p3_a8;
    ddp_party_site_rec.location.address4 := p3_a9;
    ddp_party_site_rec.location.country_code := p3_a10;
    ddp_party_site_rec.location.country := p3_a11;
    ddp_party_site_rec.location.city := p3_a12;
    ddp_party_site_rec.location.postal_code := p3_a13;
    ddp_party_site_rec.location.state := p3_a14;
    ddp_party_site_rec.location.province := p3_a15;
    ddp_party_site_rec.location.county := p3_a16;
    ddp_party_site_rec.location.last_update_date := rosetta_g_miss_date_in_map(p3_a17);
    ddp_party_site_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a18);
    ddp_party_site_rec.party_site_last_update_date := rosetta_g_miss_date_in_map(p3_a19);





    -- here's the delegated call to the old PL/SQL routine
    pv_partner_accnt_mgmt_pvt.create_party_site(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_party_site_rec,
      x_return_status,
      x_party_site_id,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end pv_partner_accnt_mgmt_pvt_w;

/
