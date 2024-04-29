--------------------------------------------------------
--  DDL for Package PN_EXP_TO_AR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_EXP_TO_AR" AUTHID CURRENT_USER as
  -- $Header: PNTXBILS.pls 120.5 2006/08/10 07:43:45 hrodda ship $

-------------------------------------------------------------------
-- For setting PN's Invoice Info
-- ( Run as a Conc Process )
-------------------------------------------------------------------
Procedure EXP_TO_AR (
                      errbuf               OUT NOCOPY        VARCHAR2
                     ,retcode              OUT NOCOPY        VARCHAR2
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
                     ,p_customer_id        NUMBER
                     ,p_grp_param          VARCHAR2 DEFAULT NULL
                     );

/* Call this procedure if a Grouping Rule on some Optional Attribute is specified */
Procedure EXP_TO_AR_GRP (
   errbuf          IN OUT NOCOPY     VARCHAR2
  ,retcode         IN OUT NOCOPY     VARCHAR2
  ,p_groupId                         VARCHAR2
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
  ,p_customer_id        NUMBER
  ,p_grp_param          VARCHAR2 DEFAULT NULL
);

/* Call this procedure if the Default Grouping Rule is specified */
Procedure EXP_TO_AR_NO_GRP (
  errbuf          IN OUT NOCOPY      VARCHAR2
  ,retcode         IN OUT NOCOPY     VARCHAR2
  ,p_groupId                         VARCHAR2
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
  ,p_customer_id        NUMBER
  ,p_grp_param          VARCHAR2 DEFAULT NULL
);

PROCEDURE do_binding (p_cursor             NUMBER
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
                     ,p_customer_id        NUMBER
                     ,p_grp_param          VARCHAR2
                     );

/* A Record to hold all the neccessary attributes for exporting */
TYPE exp_ar_rec IS RECORD (
        pn_payment_item_id            PN_PAYMENT_ITEMS.payment_item_id%TYPE
       ,pn_payment_term_id            PN_PAYMENT_ITEMS.payment_term_id%TYPE
       ,pn_export_currency_code       PN_PAYMENT_ITEMS.export_currency_code%TYPE
       ,pn_export_currency_amount     PN_PAYMENT_ITEMS.export_currency_amount%TYPE
       ,pn_customer_id                PN_PAYMENT_ITEMS.customer_id%TYPE
       ,pn_customer_site_use_id       PN_PAYMENT_ITEMS.customer_site_use_id%TYPE
       ,pn_cust_ship_site_id          PN_PAYMENT_TERMS.cust_ship_site_id%TYPE
       ,pn_tax_code_id                PN_PAYMENT_TERMS.tax_code_id%TYPE
       ,pn_tax_classification_code    PN_PAYMENT_TERMS.tax_classification_code%TYPE
       ,pn_legal_entity_id            PN_PAYMENT_TERMS.legal_entity_id%TYPE
       ,pn_inv_rule_id                PN_PAYMENT_TERMS.inv_rule_id%TYPE
       ,pn_account_rule_id            PN_PAYMENT_TERMS.account_rule_id%TYPE
       ,pn_term_id                    PN_PAYMENT_TERMS.ap_ar_term_id%TYPE
       ,pn_trx_type_id                PN_PAYMENT_TERMS.cust_trx_type_id%TYPE
       ,pn_pay_method_id              PN_PAYMENT_TERMS.receipt_method_id%TYPE
       ,pn_po_number                  PN_PAYMENT_TERMS.cust_po_number%TYPE
       ,pn_tax_included               PN_PAYMENT_TERMS.tax_included%TYPE
       ,pn_salesrep_id                PN_PAYMENT_TERMS.salesrep_id%TYPE
       ,pn_proj_attr_catg             PN_PAYMENT_TERMS.project_attribute_category%TYPE
       ,pn_proj_attr3                 PN_PAYMENT_TERMS.project_attribute3%TYPE
       ,pn_proj_attr4                 PN_PAYMENT_TERMS.project_attribute4%TYPE
       ,pn_proj_attr5                 PN_PAYMENT_TERMS.project_attribute5%TYPE
       ,pn_proj_attr6                 PN_PAYMENT_TERMS.project_attribute6%TYPE
       ,pn_proj_attr7                 PN_PAYMENT_TERMS.project_attribute7%TYPE
       ,pn_org_id                     PN_PAYMENT_TERMS.org_id%TYPE
       ,pn_lease_num                  PN_LEASES.lease_num%TYPE
       ,pn_payment_schedule_id        PN_PAYMENT_ITEMS.payment_schedule_id%TYPE
       ,pn_period_name                PN_PAYMENT_SCHEDULES.period_name%TYPE
       ,pn_description                PN_PAYMENT_TERMS.payment_purpose_code%TYPE
       ,pn_lease_id                   PN_LEASES.lease_id%TYPE
       ,transaction_date              PN_PAYMENT_ITEMS.due_date%TYPE
       ,normalize                     PN_PAYMENT_TERMS.normalize%TYPE
       ,pn_accounted_date             PN_PAYMENT_ITEMS.accounted_date%TYPE
       ,pn_rate                       PN_PAYMENT_ITEMS.rate%TYPE
       ,location_id                   PN_LOCATIONS.LOCATION_ID%TYPE
       ,send_entries                  PN_LEASE_DETAILS.send_entries%TYPE
       ,rec_account                   PN_DISTRIBUTIONS.account_id%TYPE
       ,gl_date                       RA_CUST_TRX_LINE_GL_DIST.gl_date%TYPE
       ,conv_rate_type                PN_CURRENCIES.conversion_type%TYPE
       ,conv_rate                     PN_PAYMENT_ITEMS.rate%TYPE
       ,set_of_books_id               NUMBER
       ,payment_purpose               PN_PAYMENT_TERMS.payment_purpose_code%TYPE
       ,payment_type                  PN_PAYMENT_TERMS.payment_term_type_code%TYPE
       ,rule_gl_date                  RA_CUST_TRX_LINE_GL_DIST.gl_date%TYPE
       ,schedule_date                 pn_payment_schedules_all.schedule_date%TYPE
       );

/* Declare a PL/SQL table of above record */
TYPE exp_ar_tbl_type IS TABLE OF exp_ar_rec INDEX BY BINARY_INTEGER;

END PN_EXP_TO_AR;

 

/
