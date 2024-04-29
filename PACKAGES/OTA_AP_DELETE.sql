--------------------------------------------------------
--  DDL for Package OTA_AP_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_AP_DELETE" AUTHID CURRENT_USER as
/* $Header: otdap01t.pkh 115.0 99/07/16 00:51:07 porting ship $ */
--
Procedure check_delete(p_vendor_id number default null
                      ,p_contact_id number default null
                      ,p_vendor_site_id number default null);
--
end ota_ap_delete;

 

/
