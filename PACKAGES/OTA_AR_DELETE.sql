--------------------------------------------------------
--  DDL for Package OTA_AR_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_AR_DELETE" AUTHID CURRENT_USER as
/* $Header: otdar01t.pkh 115.0 99/07/16 00:51:15 porting ship $ */
--
Procedure check_delete(p_customer_id number default null
                      ,p_contact_id  number default null
                      ,p_address_id  number default null);
--
end ota_ar_delete;

 

/
