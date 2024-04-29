--------------------------------------------------------
--  DDL for Package ISC_MAINT_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_CURRENCY_PKG" 
/* $Header: iscmaintccys.pls 120.0 2005/05/25 17:31:11 appldev noship $ */
AUTHID CURRENT_USER as
function get_org_currency
( p_selected_org   in varchar2
) return varchar2;

end isc_maint_currency_pkg;

 

/
