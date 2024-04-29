--------------------------------------------------------
--  DDL for Package ARP_PROCESS_RECUR_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_RECUR_COVER" AUTHID CURRENT_USER AS
/* $Header: ARTERCCS.pls 120.3 2006/01/17 15:36:37 vcrisost ship $ */


PROCEDURE insert_recur_cover(    p_form_name            IN varchar2,
                                 p_form_version         IN NUMBER,
                                 p_customer_trx_id      IN ra_recur_interim.customer_trx_id%type,
                                 p_trx_number           IN ra_recur_interim.trx_number%type,
                                 p_trx_date             IN ra_recur_interim.trx_date%type,
                                 p_term_due_date        IN ra_recur_interim.term_due_date%type,
                                 p_gl_date              IN ra_recur_interim.gl_date%type,
                                 p_term_discount_date   IN ra_recur_interim.term_discount_date%type,
                                 p_request_id           IN ra_recur_interim.request_id%type,
                                 p_doc_sequence_value   IN ra_recur_interim.doc_sequence_value%type,
                                 p_new_customer_trx_id  IN ra_recur_interim.new_customer_trx_id%type,
                                 p_batch_source_id      IN ra_batch_sources.batch_source_id%type,
                                 p_cust_trx_type_id     IN number,
                                 p_trx_no               OUT NOCOPY ra_recur_interim.trx_number%type,
                                 p_billing_date         IN ra_recur_interim.billing_date%type DEFAULT NULL
);

END ARP_PROCESS_RECUR_COVER;

 

/
