--------------------------------------------------------
--  DDL for Package OPI_DBI_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_CURRENCY_PKG" AUTHID CURRENT_USER AS
/* $Header: OPICURRS.pls 115.0 2002/10/11 21:07:59 csheu noship $ */

FUNCTION get_ou(p_selected_org IN varchar2) RETURN NUMBER;

FUNCTION get_global_currency RETURN VARCHAR2;

FUNCTION get_display_currency( p_currency_code		     	IN varchar2,
			       p_selected_org      		IN varchar2,
                               p_org_type IN varchar2 default 'O') return varchar2;


End OPI_DBI_CURRENCY_PKG;

 

/
