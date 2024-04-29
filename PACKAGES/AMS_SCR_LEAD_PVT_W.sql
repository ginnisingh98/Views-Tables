--------------------------------------------------------
--  DDL for Package AMS_SCR_LEAD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCR_LEAD_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswslds.pls 115.0 2002/12/26 01:27:15 sodixit noship $ */
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
  );
end ams_scr_lead_pvt_w;

 

/
