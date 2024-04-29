--------------------------------------------------------
--  DDL for Package PN_EXP_TO_AP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_EXP_TO_AP" AUTHID CURRENT_USER as
  -- $Header: PNTXPMTS.pls 120.5 2005/12/01 11:17:31 hrodda ship $

  FUNCTION get_liability_acc(p_payment_term_id NUMBER
                            ,p_vendor_id       NUMBER
                            ,p_vendor_site_id  NUMBER) RETURN NUMBER;

  PROCEDURE populate_group_by_flags(p_grouping_rule_id IN NUMBER);

  PROCEDURE get_order_by_grpby;

  PROCEDURE cache_exp_items(
                           p_lease_num_low      VARCHAR2,
                           p_lease_num_high     VARCHAR2,
                           p_sch_dt_low         VARCHAR2,
                           p_sch_dt_high        VARCHAR2,
                           p_due_dt_low         VARCHAR2,
                           p_due_dt_high        VARCHAR2,
                           p_pay_prps_code      VARCHAR2,
                           p_prd_name           VARCHAR2,
                           p_amt_low            NUMBER,
                           p_amt_high           NUMBER,
                           p_vendor_id          NUMBER,
                           p_inv_num            VARCHAR2,
                           p_grp_param          VARCHAR2);

  PROCEDURE group_and_export_items(errbuf    IN OUT NOCOPY     VARCHAR2
                                  ,retcode   IN OUT NOCOPY     NUMBER
                                  ,p_group_id                  VARCHAR2
                                  ,p_param_where_clause        VARCHAR2 DEFAULT NULL);

  PROCEDURE export_items_nogrp(errbuf    IN OUT NOCOPY     VARCHAR2
                              ,retcode   IN OUT NOCOPY     NUMBER
                              ,p_group_id                  VARCHAR2
                              ,p_param_where_clause        VARCHAR2 DEFAULT NULL);

  -------------------------------------------------------------------
  -- For loading PN's Invoice Info into AP's Interface Tables
  -- ( Run as a Conc Process )
  -------------------------------------------------------------------

  PROCEDURE exp_to_ap(errbuf    OUT NOCOPY VARCHAR2
                     ,retcode   OUT NOCOPY NUMBER
                     ,p_lease_num_low      VARCHAR2
                     ,p_lease_num_high     VARCHAR2
                     ,p_sch_dt_low         VARCHAR2
                     ,p_sch_dt_high        VARCHAR2
                     ,p_due_dt_low         VARCHAR2
                     ,p_due_dt_high        VARCHAR2
                     ,p_pay_prps_code      VARCHAR2
                     ,p_prd_name           VARCHAR2
                     ,p_amt_low            NUMBER
                     ,p_amt_high           NUMBER
                     ,p_vendor_id          NUMBER
                     ,p_inv_num            VARCHAR2
                     ,p_grp_param          VARCHAR2 DEFAULT NULL);

    -- export to AP record type
    TYPE exp_ap_rec_typ IS RECORD
    (org_id                    PN_PAYMENT_ITEMS.org_id%TYPE
    ,pn_payment_item_id        PN_PAYMENT_ITEMS.payment_item_id%TYPE
    ,pn_payment_term_id        PN_PAYMENT_ITEMS.payment_term_id%TYPE
    ,pn_export_currency_amount PN_PAYMENT_ITEMS.export_currency_amount%TYPE
    ,pn_export_currency_code   PN_PAYMENT_ITEMS.export_currency_code%TYPE
    ,pn_vendor_id              PN_PAYMENT_ITEMS.vendor_id%TYPE
    ,pn_vendor_site_id         PN_PAYMENT_ITEMS.vendor_site_id%TYPE
    ,pn_project_id             PN_PAYMENT_TERMS.project_id%TYPE
    ,pn_task_id                PN_PAYMENT_TERMS.task_id%TYPE
    ,pn_organization_id        PN_PAYMENT_TERMS.organization_id%TYPE
    ,pn_expenditure_type       PN_PAYMENT_TERMS.expenditure_type%TYPE
    ,pn_expenditure_item_date  PN_PAYMENT_TERMS.expenditure_item_date%TYPE
    ,pn_tax_group_id           PN_PAYMENT_TERMS.tax_group_id%TYPE
    ,pn_tax_code_id            PN_PAYMENT_TERMS.tax_code_id%TYPE
    ,pn_tax_classification_code PN_PAYMENT_TERMS.tax_classification_code%TYPE
    ,pn_tax_included           PN_PAYMENT_TERMS.tax_included%TYPE
    ,pn_distribution_set_id    PN_PAYMENT_TERMS.distribution_set_id%TYPE
    ,pn_lease_num              PN_LEASES.lease_num%TYPE
    ,pn_lease_id               PN_LEASES.lease_id%TYPE
    ,pn_send_entries           PN_LEASE_DETAILS.send_entries%TYPE
    ,pn_payment_schedule_id    PN_PAYMENT_ITEMS.payment_schedule_id%TYPE
    ,pn_period_name            PN_PAYMENT_SCHEDULES.period_name%TYPE
    ,gl_date                   DATE
    ,pn_normalize              PN_PAYMENT_TERMS.normalize%TYPE
    ,pn_due_date               PN_PAYMENT_ITEMS.due_date%TYPE
    ,pn_ap_ar_term_id          PN_PAYMENT_TERMS.ap_ar_term_id%TYPE
    ,pn_accounted_date         PN_PAYMENT_ITEMS.accounted_date%TYPE
    ,pn_rate                   PN_PAYMENT_ITEMS.rate%TYPE
    ,pn_ap_invoice_num         PN_PAYMENT_ITEMS.ap_invoice_num%TYPE
    ,pn_payment_purpose_code   PN_PAYMENT_TERMS.payment_purpose_code%TYPE
    ,pn_payment_term_type_code PN_PAYMENT_TERMS.payment_term_type_code%TYPE
    ,pn_lia_account            PN_DISTRIBUTIONS.account_id%TYPE
    ,pn_legal_entity_id        PN_PAYMENT_TERMS.legal_entity_id%TYPE
    ,conv_rate                 PN_PAYMENT_ITEMS.rate%TYPE
    ,conv_rate_type            PN_CURRENCIES.conversion_type%TYPE
    ,item_grouping_rule_id     PN_PAYMENT_ITEMS.grouping_rule_id%TYPE
    ,term_grouping_rule_id     PN_PAYMENT_TERMS.grouping_rule_id%TYPE
    ,lease_grouping_rule_id    PN_LEASE_DETAILS.grouping_rule_id%TYPE
    ,processed                 VARCHAR2(1));

    -- export items cache table type
    TYPE exp_ap_tbl_typ IS TABLE OF exp_ap_rec_typ INDEX BY BINARY_INTEGER;

END PN_EXP_TO_AP;

 

/
