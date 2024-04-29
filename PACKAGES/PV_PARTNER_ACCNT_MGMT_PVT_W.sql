--------------------------------------------------------
--  DDL for Package PV_PARTNER_ACCNT_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_ACCNT_MGMT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: pvxwpams.pls 120.1 2005/09/08 13:14 appldev ship $ */
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
  );
end pv_partner_accnt_mgmt_pvt_w;

 

/
