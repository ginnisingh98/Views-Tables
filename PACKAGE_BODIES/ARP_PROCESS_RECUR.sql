--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_RECUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_RECUR" AS
/* $Header: ARTERECB.pls 120.2 2002/11/18 22:42:26 anukumar ship $ */

FUNCTION create_inv_conc_req(p_create_flag IN varchar2) return
NUMBER is
l_request_id number ;
Begin
  arp_util.debug(' arp_process_recur.create_inv_conc_req()+');
  l_request_id := fnd_request.submit_request('AR','ARXREC',NULL,SYSDATE,FALSE,'Y');
  return(l_request_id);
  arp_util.debug(' arp_process_recur.create_inv_conc_req()-');
End;


FUNCTION get_due_date(p_term_id IN NUMBER,p_trx_date IN date) return
DATE is
l_due_date DATE;
Begin

  arp_util.debug(' arp_process_recur.get_due_date()+');
  l_due_date := arpt_sql_func_util.Get_First_Due_Date(p_term_id,p_trx_date);
  return(l_due_date);
  arp_util.debug(' arp_process_recur.get_due_date()-');
End;


FUNCTION get_auto_trx_numbering_flag(p_batch_source_id IN NUMBER) return
VARCHAR2 is
l_auto_trx_numbering_flag VARCHAR2(1) ;
Begin
  arp_util.debug(' arp_process_recur.get_auto_trx_numbering_flag()+');
      IF    ( p_batch_source_id  IS NULL )
      THEN  RETURN( 'N' );
      ELSE
            SELECT  auto_trx_numbering_flag
            INTO   l_auto_trx_numbering_flag
            FROM   RA_BATCH_SOURCES
            WHERE  batch_source_id = p_batch_source_id;

            RETURN(l_auto_trx_numbering_flag);
      END IF;
  arp_util.debug(' arp_process_recur.get_auto_trx_numbering_flag()-');
EXCEPTION
WHEN OTHERS THEN
arp_util.debug(' EXCEPTION :arp_process_recur.get_auto_trx_numbering_flag()-');
RAISE;
End;


FUNCTION get_transaction_amount(
   p_customer_trx_id        IN  number,
   p_line_type              IN  varchar2)
return NUMBER is
   l_amount NUMBER ;
   l_amount_trx NUMBER;
   l_amount_trx_total_rtot_db NUMBER;
Begin
   arp_util.debug(' arp_process_recur.get_transaction_amount()+');
   arp_ctl_sum_pkg.select_summary(p_customer_trx_id ,
                                  p_line_type,
                                  l_amount_trx,
                                  l_amount_trx_total_rtot_db);
   l_amount := l_amount_trx;
   arp_util.debug(' arp_process_recur.get_transaction_amount()-');
   RETURN(l_amount);

EXCEPTION
WHEN OTHERS THEN
RAISE;
End;

PROCEDURE insert_recur(    p_form_name         IN varchar2,
                           p_form_version      IN number,
                           p_rec_rec           IN ra_recur_interim%rowtype,
                           p_batch_source_id   IN ra_batch_sources.batch_source_id%type,
                           p_cust_trx_type_id  IN number,
                           p_trx_no  OUT NOCOPY ra_recur_interim.trx_number%type) IS

    l_trx_no ra_recur_interim.trx_number%type;

Begin

     -- validate that the transaction and document numbers are unique

     arp_trx_validate.validate_trx_number( p_batch_source_id,
                                           p_rec_rec.trx_number,
                                           p_rec_rec.new_customer_trx_id);

     arp_trx_validate.validate_doc_number( p_cust_trx_type_id,
                                           p_rec_rec.doc_sequence_value,
                                           p_rec_rec.new_customer_trx_id);


       -- call table handler
     ARP_RECUR_PKG.insert_p(p_rec_rec, p_batch_source_id,l_trx_no);
     p_trx_no := l_trx_no;
     arp_util.debug('  p_form_name            : '||p_form_name );
     arp_util.debug('  insert_recur            : '||l_trx_no );

EXCEPTION
   when OTHERS THEN
     -- display all relevent information
     arp_util.debug('EXCEPTION: arp_process_recur.insert_recur()');
     arp_util.debug('  p_form_name            : '||p_form_name );
     arp_util.debug('  p_form_version         : '||p_form_version);
     RAISE;

END;

END ARP_PROCESS_RECUR;

/
