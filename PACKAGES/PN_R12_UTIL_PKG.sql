--------------------------------------------------------
--  DDL for Package PN_R12_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_R12_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: PNUTL12S.pls 120.7 2006/06/21 04:50:00 hrodda noship $ */

FUNCTION get_tcc (
            p_tax_code_id        pn_payment_terms.tax_code_id%TYPE,
            p_lease_class_code   pn_leases.lease_class_code%TYPE,
            p_as_of_date         pn_payment_terms.start_date%TYPE)
RETURN VARCHAR2;

FUNCTION get_tcc_name (
            p_tcc                pn_payment_terms.tax_classification_code%TYPE,
            p_lease_class_code   pn_leases.lease_class_code%TYPE,
            p_org_id             pn_term_templates.org_id%TYPE)
RETURN VARCHAR2;

FUNCTION validate_term_template_tax(
           p_term_temp_id   IN    NUMBER,
           p_lease_cls_code IN    VARCHAR2)
RETURN BOOLEAN;

FUNCTION is_le_compatible(
           p_ccid             IN pn_distributions.account_id%TYPE,
           p_payment_term_id  IN pn_payment_terms.payment_term_id%TYPE DEFAULT NULL,
           p_term_template_id IN pn_payment_terms.term_template_id%TYPE DEFAULT NULL,
           p_vendor_site_id   IN pn_payment_terms.vendor_site_id%TYPE,
           p_org_id           IN pn_payment_terms.org_id%TYPE,
           p_distribution_id  IN pn_distributions.distribution_id%TYPE DEFAULT NULL,
           p_mode             IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION is_r12
RETURN BOOLEAN;

FUNCTION get_le_for_ar(
           p_customer_id         pn_payment_terms.customer_id%TYPE
          ,p_transaction_type_id pn_payment_terms.cust_trx_type_id%TYPE
          ,p_org_id              pn_payment_terms.org_id%TYPE)
RETURN NUMBER;

FUNCTION get_le_for_ap(
           p_code_combination_id pn_distributions.account_id%TYPE
          ,p_location_id         pn_payment_terms.vendor_site_id%TYPE
          ,p_org_id              pn_payment_terms.org_id%TYPE)
RETURN NUMBER;

FUNCTION get_tax_flag(p_vendor_id      IN NUMBER,
                      p_vendor_site_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_ap_tax_code_name(p_tax_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_ar_tax_code_name (p_tax_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_tax_group ( p_tax_group_id   NUMBER)
RETURN VARCHAR2;

FUNCTION check_tax_upgrade (p_tax_code_id  pn_payment_terms.tax_code_id%TYPE,
                            p_tax_group_id pn_payment_terms.tax_group_id%TYPE,
                            p_run_mode     pn_leases.lease_class_code%TYPE)
RETURN VARCHAR2;

FUNCTION check_tax_upgrade (p_term_template_id pn_term_templates.term_template_id%TYPE)
RETURN VARCHAR2;

END pn_r12_util_pkg;

 

/
