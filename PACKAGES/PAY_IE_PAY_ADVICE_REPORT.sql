--------------------------------------------------------
--  DDL for Package PAY_IE_PAY_ADVICE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PAY_ADVICE_REPORT" AUTHID CURRENT_USER as
/* $Header: pyiersoe.pkh 115.0 2003/09/15 10:42:26 vmkhande noship $ */

   Function get_address_line_1 (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2;
   Function get_address_line_2 (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2;
   Function get_address_line_3 (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2;
 -- region 1 is county
   Function get_region_1       (p_location_code varchar2,
                               p_business_group_id varchar2,
                               p_effective_date Date)
   return varchar2;
   Function get_region_2   (p_location_code varchar2,
                               p_business_group_id varchar2)
   return varchar2;
   Function get_country       (p_location_code varchar2,
                               p_business_group_id varchar2)
  return varchar2;
end;

 

/
