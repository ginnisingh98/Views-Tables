--------------------------------------------------------
--  DDL for Package EDW_GEOGRAPHY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_GEOGRAPHY_PKG" AUTHID CURRENT_USER AS
/* $Header: poafkge.pkh 120.1 2005/06/13 12:39:15 sriswami noship $  */

  Function HR_Location_fk
               (p_location_id   in NUMBER,
                p_instance_code in VARCHAR2 :=NULL) return VARCHAR2;

  Function HZ_Postcode_City_fk
               (p_location_id   in NUMBER) return VARCHAR2;

  Function Customer_Site_Location_fk
               (p_site_use_id   in NUMBER,
                p_instance_code in VARCHAR2 :=NULL) return VARCHAR2;

  Function Supplier_Site_Location_fk
               (p_vendor_site_id in NUMBER,
                p_org_id         in NUMBER,
                p_instance_code  in VARCHAR2 :=NULL) return VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (HR_Location_fk,
                                             WNDS, WNPS, RNPS);

  PRAGMA RESTRICT_REFERENCES (HZ_Postcode_City_fk,
                                            WNDS, WNPS, RNPS);

  PRAGMA RESTRICT_REFERENCES (Customer_Site_Location_fk,
                                             WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES (Supplier_Site_Location_fk,
                                             WNDS, WNPS, RNPS);

/* For 11.5, new customer model, used by CRM */
  Function Party_Site_Location_fk
               (p_party_site_id in NUMBER,
                p_instance_code in VARCHAR2 :=NULL) return VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (Party_Site_Location_fk,
                                             WNDS, WNPS, RNPS);

end;

 

/
