--------------------------------------------------------
--  DDL for Package MSCX_UI_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSCX_UI_UTILITIES" AUTHID CURRENT_USER AS
-- $Header: MSCXUIPS.pls 120.0 2005/05/25 18:36:00 appldev noship $




Function get_responsibility_key
return varchar2 ;

Function get_company_name(grantee_key number)
return varchar2 ;

Function get_user_name(grantee_key number)
return varchar2 ;

Function get_responsibility_name(grantee_key number)
return varchar2 ;

Function get_group_name(grantee_key number)
return varchar2 ;

Function get_site_name(p_site_id number)
return varchar2 ;

Function get_item_name(p_item_id number)
return varchar2 ;

Function get_order_type_meaning(p_order_type number)
return varchar2 ;

Function get_grantee_type_meaning(p_grantee_type varchar2)
return varchar2 ;

Function get_privilege_meaning(p_privilege varchar2)
return varchar2 ;




END MSCX_UI_UTILITIES;

 

/
