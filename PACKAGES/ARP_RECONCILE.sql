--------------------------------------------------------
--  DDL for Package ARP_RECONCILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RECONCILE" AUTHID CURRENT_USER AS
/* $Header: ARTRECBS.pls 115.3 2002/11/15 03:58:05 anukumar ship $ */

/*=======================================================================+
 |  Public Variables and Record Types
 +=======================================================================*/
SUBTYPE ae_doc_rec_type   IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_event_rec_type IS ARP_ACCT_MAIN.ae_event_rec_type;
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;
SUBTYPE ae_line_rec_type  IS ARP_ACCT_MAIN.ae_line_rec_type;
SUBTYPE ae_line_tbl_type  IS ARP_ACCT_MAIN.ae_line_tbl_type;
SUBTYPE ae_rule_rec_type  IS ARP_ACCT_MAIN.ae_app_rule_rec_type;

TYPE get_recon_rec_type IS RECORD
(
source_type			AR_DISTRIBUTIONS.source_type%TYPE,
source_id_secondary           	AR_DISTRIBUTIONS.source_id_secondary%TYPE,
source_table_secondary        	AR_DISTRIBUTIONS.source_table_secondary%TYPE,
source_type_secondary         	AR_DISTRIBUTIONS.source_type_secondary%TYPE,
currency_code            	AR_DISTRIBUTIONS.currency_code%TYPE,
currency_conversion_rate 	AR_DISTRIBUTIONS.currency_conversion_rate%TYPE,
currency_conversion_type 	AR_DISTRIBUTIONS.currency_conversion_type%TYPE,
currency_conversion_date 	AR_DISTRIBUTIONS.currency_conversion_date%TYPE,
third_party_id           	AR_DISTRIBUTIONS.third_party_id%TYPE,
third_party_sub_id       	AR_DISTRIBUTIONS.third_party_sub_id%TYPE,
reversed_source_id       	AR_DISTRIBUTIONS.reversed_source_id%TYPE,
amount                   	AR_DISTRIBUTIONS.amount_cr%TYPE,
acctd_amount             	AR_DISTRIBUTIONS.acctd_amount_cr%TYPE,
taxable_entered          	AR_DISTRIBUTIONS.taxable_entered_cr%TYPE,
taxable_accounted        	AR_DISTRIBUTIONS.taxable_accounted_cr%TYPE,
location_segment_id           	AR_DISTRIBUTIONS.location_segment_id%TYPE,
tax_group_code_id             	AR_DISTRIBUTIONS.tax_group_code_id%TYPE,
tax_code_id                   	AR_DISTRIBUTIONS.tax_code_id%TYPE,
code_combination_id           	AR_DISTRIBUTIONS.code_combination_id%TYPE);


/*========================================================================
 | PUBLIC PROCEDURE Reconcile_BR_Tax
 |
 | DESCRIPTION
 |      On closure of a Bills Receivable document simulates an application activity
 |      against the shadow adjustments on the Bills line assignment, retrieves the
 |      actual accounting created for the Bill and reconciles the deferred tax.
 |      A difference if any is created in the distributions table.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_sys_rec    IN      System parameter details
 |      p_cust_inv_rec  IN      Contains currency, exchange rate, site
 |                              details for the bill
 |      p_ae_ctr        IN OUT NOCOPY  counter for lines table
 |      p_ae_line_tbl   IN OUT NOCOPY  lines table containing reconciled entry
 *=======================================================================*/
PROCEDURE Reconcile_trx_br(p_mode                   IN             VARCHAR2                     ,
                           p_ae_doc_rec             IN             ae_doc_rec_type              ,
                           p_ae_event_rec           IN             ae_event_rec_type            ,
                           p_cust_inv_rec           IN             ra_customer_trx%ROWTYPE      ,
                           p_activity_cust_trx_id   IN             NUMBER                       ,
                           p_activity_amt           IN             NUMBER                       ,
                           p_activity_acctd_amt     IN             NUMBER                       ,
                           p_call_num               IN             NUMBER                       ,
                           p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type             ,
                           p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                );
END ARP_RECONCILE;


 

/
