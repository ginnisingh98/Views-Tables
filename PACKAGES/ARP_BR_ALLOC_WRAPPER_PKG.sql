--------------------------------------------------------
--  DDL for Package ARP_BR_ALLOC_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_BR_ALLOC_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTWRAPS.pls 115.2 2002/11/15 04:07:56 anukumar noship $ */

/*=======================================================================+
 |  Public Variables and Record Types
 +=======================================================================*/
SUBTYPE ae_doc_rec_type   IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_event_rec_type IS ARP_ACCT_MAIN.ae_event_rec_type;
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;
SUBTYPE ae_line_rec_type  IS ARP_ACCT_MAIN.ae_line_rec_type;
SUBTYPE ae_line_tbl_type  IS ARP_ACCT_MAIN.ae_line_tbl_type;
SUBTYPE ae_curr_rec_type  IS ARP_ACCT_MAIN.ae_curr_rec_type;
SUBTYPE ae_rule_rec_type  IS ARP_ACCT_MAIN.ae_app_rule_rec_type;

PROCEDURE Allocate_Tax_BR_Main(
                 p_mode                   IN      VARCHAR2                            ,
                 p_ae_doc_rec             IN      ae_doc_rec_type                     ,
                 p_ae_event_rec           IN      ae_event_rec_type                   ,
                 p_ae_rule_rec            IN      ae_rule_rec_type                    ,
                 p_app_rec                IN      ar_receivable_applications%ROWTYPE  ,
                 p_cust_inv_rec           IN      ra_customer_trx%ROWTYPE             ,
                 p_adj_rec                IN      ar_adjustments%ROWTYPE              ,
                 p_ae_sys_rec             IN      ae_sys_rec_type                     ,
                 p_ae_ctr                 IN OUT NOCOPY  BINARY_INTEGER                      ,
                 p_ae_line_tbl            IN OUT NOCOPY  ae_line_tbl_type);

END ARP_BR_ALLOC_WRAPPER_PKG;

 

/
