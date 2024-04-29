--------------------------------------------------------
--  DDL for Package ARP_PROCESS_RECUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_RECUR" AUTHID CURRENT_USER AS
/* $Header: ARTERECS.pls 115.3 2002/11/15 03:46:18 anukumar ship $ */

FUNCTION  create_inv_conc_req( p_create_flag IN VARCHAR2) return NUMBER;
FUNCTION  get_due_date( p_term_id IN NUMBER,p_trx_date IN DATE) return DATE;
FUNCTION  get_auto_trx_numbering_flag(p_batch_source_id IN NUMBER) return VARCHAR2;
PROCEDURE insert_recur(    p_form_name IN varchar2,
                           p_form_version IN number,
                           p_rec_rec IN ra_recur_interim%rowtype,
                           p_batch_source_id IN ra_batch_sources.batch_source_id%type,
                           p_cust_trx_type_id  IN number,
                           p_trx_no  OUT NOCOPY ra_recur_interim.trx_number%type);

FUNCTION get_transaction_amount(
   p_customer_trx_id        IN  number,
   p_line_type              IN  varchar2)
   return NUMBER;

END ARP_PROCESS_RECUR;

 

/
