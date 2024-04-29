--------------------------------------------------------
--  DDL for Package EDW_TRD_PARTNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_TRD_PARTNER_PKG" AUTHID CURRENT_USER AS
/* $Header: poafktps.pls 120.0 2005/06/02 02:00:24 appldev noship $ */

 Function supplier_site_fk(p_vendor_site_id in NUMBER,
                           p_org_id         in NUMBER,
                           p_instance_code  in VARCHAR2 := NULL) return VARCHAR2;

 Function supplier_fk(p_vendor_id      in NUMBER,
                      p_instance_code  in VARCHAR2 := NULL) return VARCHAR2;

 Function customer_fk (p_cust_account_id in NUMBER,
                       p_instance_code   in VARCHAR2 := NULL) return VARCHAR2;

 Function customer_site_fk (p_site_use_id     in NUMBER,
                            p_instance_code   in VARCHAR2 := NULL) return VARCHAR2;

 Function party_fk (p_party_id	in NUMBER,
                    p_instance_code   in VARCHAR2 := NULL) return VARCHAR2;

 PRAGMA RESTRICT_REFERENCES (supplier_site_fk, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES (supplier_fk, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES (customer_fk, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES (customer_site_fk, WNDS, WNPS, RNPS);
 PRAGMA RESTRICT_REFERENCES (party_fk, WNDS, WNPS, RNPS);

End EDW_TRD_PARTNER_PKG;

 

/
