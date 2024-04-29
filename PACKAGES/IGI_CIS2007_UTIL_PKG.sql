--------------------------------------------------------
--  DDL for Package IGI_CIS2007_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: igiputls.pls 120.1.12010000.4 2017/04/12 13:47:04 sthatich ship $


    /*
    * Type: Procedure
    * Access: Public API
    *
    * Description: This function calls the certificate insertion logic
    * for the supplier if CIS is enabled
    *
    * Note: This procedure is called from package AP_VENDORS_PKG (apvndhrb.pls)
    * Modifying the package spec will cause the package AP_VENDORS_PKG to fail
    */
    PROCEDURE SUPPLIER_UPDATE(
        p_vendor_id IN ap_suppliers.vendor_id%TYPE,
        p_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE,
        p_pay_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE		 /* Bug 7218825 */
    );

    /*
    * Type: Procedure
    * Access: Public API
    *
    * Description: This function calls the certificate insertion logic
    * for supplier site if CIS is enabled
    *
    * Note: This procedure is called from package AP_VENDOR_SITES_PKG (apvndsib.pls)
    * Modifying the package spec will cause the package AP_VENDOR_SITES_PKG to fail
    */
    PROCEDURE SUPPLIER_SITE_UPDATE(
        p_vendor_id IN ap_suppliers.vendor_id%TYPE,
        p_vendor_site_id IN ap_supplier_sites_all.vendor_site_id%TYPE,
        p_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE,
        p_pay_tax_grp_id IN ap_awt_group_taxes_all.group_id%TYPE	        /* Bug 7218825 */
    );

/* The Below Function Added for CIS Bug 7218825 */

    FUNCTION get_payables_option_based_awt(l_vendor_id NUMBER,l_vendor_site_id NUMBER,l_tax_grp_id NUMBER,l_pay_tax_grp_id NUMBER) RETURN NUMBER;

END IGI_CIS2007_UTIL_PKG;


/
