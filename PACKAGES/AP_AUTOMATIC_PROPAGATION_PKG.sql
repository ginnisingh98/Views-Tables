--------------------------------------------------------
--  DDL for Package AP_AUTOMATIC_PROPAGATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AUTOMATIC_PROPAGATION_PKG" AUTHID CURRENT_USER AS
/* $Header: apautprs.pls 120.0.12010000.3 2010/03/03 16:50:26 dawasthi noship $ */

  FUNCTION Get_Affected_Invoices_Count(
    P_external_bank_account_id iby_ext_bank_accounts.ext_bank_account_id%TYPE,
    P_vendor_id                ap_suppliers.vendor_id%TYPE,
    P_vendor_site_id           ap_supplier_sites.vendor_site_id%TYPE DEFAULT NULL,
    P_party_Site_Id            ap_supplier_sites.party_site_id%TYPE  DEFAULT NULL,
    P_org_id                   ap_invoices.org_id%TYPE  DEFAULT NULL
    ) RETURN NUMBER;


  PROCEDURE Update_Payment_Schedules (
      p_from_bank_account_id iby_ext_bank_accounts.ext_bank_account_id%TYPE,
      p_to_bank_account_id   iby_ext_bank_accounts.ext_bank_account_id%TYPE,
      p_vendor_id            ap_suppliers.vendor_id%TYPE,
      P_vendor_site_id       ap_supplier_sites.vendor_site_id%TYPE DEFAULT NULL,
      P_party_Site_Id        ap_supplier_sites.party_site_id%TYPE  DEFAULT NULL,
      P_org_id               ap_invoices.org_id%TYPE  DEFAULT NULL,
      P_party_id             ap_suppliers.party_id%TYPE	DEFAULT NULL		-- Added for bug 9410719
     );

END AP_AUTOMATIC_PROPAGATION_PKG;

/
