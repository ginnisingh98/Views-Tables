--------------------------------------------------------
--  DDL for Package ISC_DBI_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_CURRENCY_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCCURRS.pls 120.0 2005/05/25 17:41:39 appldev noship $ */

FUNCTION is_sec_curr_defined return varchar2;

FUNCTION get_ou(p_selected_org IN varchar2) RETURN NUMBER;

FUNCTION get_display_currency(p_org_type			IN varchar2,
				p_currency_code		     	IN varchar2,
				p_selected_org      		IN varchar2) return varchar2;

FUNCTION get_cpm_display_currency(	p_currency_code	IN varchar2) return varchar2;

FUNCTION get_func_display_currency(p_org_type			IN varchar2,
				p_currency_code		     	IN varchar2,
				p_selected_org      		IN varchar2) return varchar2;

End ISC_DBI_CURRENCY_PKG;

 

/
