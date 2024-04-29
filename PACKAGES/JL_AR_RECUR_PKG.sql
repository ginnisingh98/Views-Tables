--------------------------------------------------------
--  DDL for Package JL_AR_RECUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_RECUR_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzziris.pls 115.0 99/07/16 03:15:31 porting ship $ */
PROCEDURE insert_interim(
            p_customer_trx_id     IN  ra_recur_interim.customer_trx_id%type,
            p_trx_date            IN  DATE,
            p_term_due_date       IN  DATE,
            p_gl_date             IN  DATE,
            p_term_discount_date  IN  DATE,
            p_request_id          IN  ra_recur_interim.request_id%type,
            p_doc_sequence_value  IN  ra_recur_interim.doc_sequence_value%type,
            p_new_customer_trx_id IN  ra_recur_interim.new_customer_trx_id%type,
            p_batch_source_id     IN  ra_batch_sources.batch_source_id%type,
            p_trx_number_out      OUT ra_recur_interim.trx_number%type);
END JL_AR_RECUR_PKG;

 

/
