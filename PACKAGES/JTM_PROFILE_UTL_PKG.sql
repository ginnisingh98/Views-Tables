--------------------------------------------------------
--  DDL for Package JTM_PROFILE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_PROFILE_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: jtmpfuts.pls 120.1 2005/08/24 02:17:34 saradhak noship $ */

/* comment out to prevent user accidently call this proc
FUNCTION Get_app_level_profile_value(
          p_profile_name in varchar2,
          p_app_short_name in varchar2) return varchar2;
*/

FUNCTION Get_app_enable_flag( p_app_short_name    IN  varchar2) return varchar2;

FUNCTION Get_app_enable_flag(p_resp_id in number, p_app_id in number) return varchar2;

FUNCTION Get_enable_flag_at_resp(
    p_resp_id in number,
    p_app_short_name IN varchar2) return varchar2;

FUNCTION Get_enable_flag_at_resp(
    p_resp_key in VARCHAR2,
    p_app_short_name IN varchar2) return varchar2;

FUNCTION Get_enable_flag_at_resp(
    p_app_short_name IN varchar2) return varchar2;

END JTM_PROFILE_UTL_PKG ;

 

/
