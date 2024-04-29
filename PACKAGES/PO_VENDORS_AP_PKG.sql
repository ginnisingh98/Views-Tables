--------------------------------------------------------
--  DDL for Package PO_VENDORS_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORS_AP_PKG" AUTHID CURRENT_USER AS
/* $Header: povendrs.pls 120.2 2005/10/11 01:50:21 bghose noship $ */

    FUNCTION get_num_active_pay_sites(X_vendor_id IN NUMBER,
                                      X_ORG_ID IN NUMBER )
                                      RETURN NUMBER;
    FUNCTION get_num_inactive_pay_sites(X_vendor_id IN NUMBER,
                                      X_ORG_ID IN NUMBER )
                                      RETURN NUMBER;

END PO_VENDORS_AP_PKG;

 

/
