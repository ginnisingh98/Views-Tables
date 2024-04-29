--------------------------------------------------------
--  DDL for Package AP_WEB_DB_PO_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_PO_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbpos.pls 115.2 2003/11/06 20:42:03 kwidjaja noship $ */

--------------------------------------------------------------------------
FUNCTION IsVendorValid(p_vendor_id IN NUMBER,
                       p_effective_date IN DATE default SYSDATE
) return VARCHAR2;
--------------------------------------------------------------------------
FUNCTION IsVendorSiteValid(p_vendor_site_id IN NUMBER,
                       p_effective_date IN DATE default SYSDATE
) return VARCHAR2;
--------------------------------------------------------------------------
END AP_WEB_DB_PO_INT_PKG;

 

/
