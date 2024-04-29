--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_RECUR_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_RECUR_COVER" AS
/* $Header: ARTERCCB.pls 120.4 2006/01/17 15:36:38 vcrisost ship $ */

PROCEDURE insert_recur_cover(    p_form_name            IN varchar2 ,
                                 p_form_version         IN number,
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
                                 p_billing_date         IN ra_recur_interim.billing_date%type DEFAULT NULL) IS
  l_rec_rec                 ra_recur_interim%rowtype;
  l_trx_no                  ra_recur_interim.trx_number%type;

Begin

   arp_util.debug('arp_recur_inv.insert_recur_cover()+');
   l_rec_rec.customer_trx_id             := p_customer_trx_id;
   l_rec_rec.trx_number                  := p_trx_number;
   l_rec_rec.trx_date                    := p_trx_date;
   l_rec_rec.term_due_date               := p_term_due_date;
   l_rec_rec.gl_date                     := p_gl_date;
   l_rec_rec.term_discount_date          := p_term_discount_date;
   l_rec_rec.request_id                  := p_request_id;
   l_rec_rec.doc_sequence_value          := p_doc_sequence_value;
   l_rec_rec.new_customer_trx_id         := p_new_customer_trx_id;
   l_rec_rec.billing_date                := p_billing_date;

   arp_process_recur.insert_recur(  p_form_name,
                                p_form_version,
                                l_rec_rec,
                                p_batch_source_id,
                                p_cust_trx_type_id,
                                l_trx_no );

   p_trx_no       :=  l_trx_no;

   arp_util.debug('arp_process_recur_cover.trx_no is'||l_trx_no);
   arp_util.debug('arp_process_recur_cover.document_sequence_value is'||l_trx_no);
   arp_util.debug('arp_recur_inv.insert_recur_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_recur_inv.insert_recur_cover');
    arp_util.debug('p_form_name                  : '||p_form_name);
    arp_util.debug('p_form_version               : '||p_form_version);
    arp_util.debug('p_trx_date                   : '||p_trx_date);
    arp_util.debug('p_billing_date               : '||p_billing_date);
    arp_util.debug('p_term_due_date              : '||p_term_due_date);
    arp_util.debug('p_customer_trx_id            : '||p_customer_trx_id);
    arp_util.debug('p_customer_trx_id            : '||p_customer_trx_id);
    arp_util.debug('p_customer_trx_id            : '||p_customer_trx_id);
    arp_util.debug('p_customer_trx_id            : '||p_customer_trx_id);

    RAISE;

End;
END ARP_PROCESS_RECUR_COVER;

/
