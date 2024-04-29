--------------------------------------------------------
--  DDL for Package AS_OSI_LEAD_PUB_W2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OSI_LEAD_PUB_W2" AUTHID CURRENT_USER as
  /* $Header: asxolpbs.pls 115.2 2002/12/10 01:32:46 kichan ship $ */
  procedure osi_ccs_fetch(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure osi_ovm_fetch(p_api_version_number  NUMBER
    , p1_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
end as_osi_lead_pub_w2;

 

/
