--------------------------------------------------------
--  DDL for Package ZX_TAX_RECOVERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_RECOVERY_PKG" AUTHID CURRENT_USER AS
/* $Header: zxpotrxrecs.pls 120.1 2005/09/21 23:35:59 hongliu ship $ */

   /* Get Purchase Order Distribution Rate */

  FUNCTION Get_Po_Distribution_Rate (p_distribution_id IN   po_distributions_all.po_distribution_id%TYPE) RETURN NUMBER;

   /* Check if account in range */
 TYPE get_rec_rate_tbl1 IS TABLE OF PO_DISTRIBUTIONS_ALL.RECOVERY_RATE%TYPE INDEX BY BINARY_INTEGER;
-- pg_get_tax_recovery_rate_tab         get_rec_rate_tbl;
  FUNCTION account_in_range
  (p_passed_concat_segs   IN VARCHAR2,
   p_db_concat_segs_low   IN VARCHAR2,
   p_db_concat_segs_high  IN VARCHAR2,
   p_chart_of_accts	  IN VARCHAR2) return NUMBER ;


   /* Check if account is overlapping */

  FUNCTION account_overlap
  (p_form_concat_segs_low   IN VARCHAR2,
   p_form_concat_segs_high  IN VARCHAR2,
   p_db_concat_segs_low     IN VARCHAR2,
   p_db_concat_segs_high    IN VARCHAR2) return NUMBER ;



   /* Get Tax rule Rate */

  FUNCTION Get_Rule_Rate (p_rule                IN NUMBER,
                          p_tax_date            IN DATE default SYSDATE,
			  p_vendorclass po_vendors.vendor_type_lookup_code%TYPE,
			  p_concatenate in VARCHAR2) RETURN NUMBER;


   /* Get Default Rate */

  PROCEDURE Get_Default_Rate (p_tax_code                 IN  ap_tax_codes_all.name%TYPE,
                              p_tax_id                   IN   ap_tax_codes_all.tax_id%TYPE,
                              p_tax_date                 IN   DATE default SYSDATE,
                              p_code_combination_id      IN   gl_code_combinations.code_combination_id%TYPE,
                              p_vendor_id                IN   po_vendors.vendor_id%TYPE,
                              p_distribution_id          IN   po_distributions_all.po_distribution_id%TYPE,
                              p_tax_user_override_flag   IN   VARCHAR2,
                              p_user_tax_recovery_rate   IN   ap_tax_codes_all.tax_rate%TYPE,
                              p_concatenated_segments    IN   VARCHAR2,
                              p_vendor_site_id           IN   po_vendor_sites_all.vendor_site_id%TYPE,
                              p_inventory_item_id        IN   mtl_system_items.inventory_item_id%TYPE,
                              p_item_org_id              IN   mtl_system_items.organization_id%TYPE,
                              APPL_SHORT_NAME            IN   fnd_application.application_short_name%TYPE,
                              FUNC_SHORT_NAME            IN   VARCHAR2 default 'NONE',
                              p_calling_sequence         IN   VARCHAR2,
                              p_chart_of_accounts_id     IN   gl_ledgers.chart_of_accounts_id%TYPE,
                              p_tc_tax_recovery_rule_id  IN   ap_tax_codes_all.tax_recovery_rule_id%TYPE,
                              p_tc_tax_recovery_rate     IN   ap_tax_codes_all.tax_recovery_rate%TYPE,
                              p_vendor_type_lookup_code  IN   po_vendors.vendor_type_lookup_code%TYPE,
                              p_tax_recovery_rate        IN OUT NOCOPY number);
 END ZX_TAX_RECOVERY_PKG;

 

/
