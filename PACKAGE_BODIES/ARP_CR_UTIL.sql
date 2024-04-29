--------------------------------------------------------
--  DDL for Package Body ARP_CR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CR_UTIL" AS
/*$Header: ARRUTILB.pls 120.4 2003/11/04 20:43:40 orashid ship $*/
--
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE get_dist_ccid( P_cr_id    IN ar_cash_receipts.cash_receipt_id%TYPE,
                         P_source_table IN ar_distributions.source_table%TYPE,
                         P_source_type IN ar_distributions.source_type%TYPE,
			 P_rma_rec IN ar_receipt_method_accounts%ROWTYPE,
                         P_ccid  OUT NOCOPY ar_distributions.code_combination_id%TYPE)
IS
l_ccid ar_distributions.code_combination_id%TYPE;
--
CURSOR ar_get_crh_ccid_C IS
       SELECT dist.code_combination_id ccid
       FROM   ar_distributions dist,
              ar_cash_receipt_history crh
       WHERE  dist.source_table = 'CRH'
       AND    dist.source_id = crh.cash_receipt_history_id
       AND    dist.source_type = P_source_type
       AND    crh.cash_receipt_id = P_cr_id
       ORDER BY LINE_ID desc;
--
BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( '<<<<<<< arp_cr_util.get_dist_ccid' );
   END IF;
   --
   OPEN ar_get_crh_ccid_C;
   FETCH ar_get_crh_ccid_C INTO l_ccid;
   CLOSE ar_get_crh_ccid_C;

   IF ( P_rma_rec.receipt_method_id IS NOT NULL ) AND
      ( l_ccid IS NULL )
   THEN
        IF ( P_source_type = 'CASH' )
        THEN
           l_ccid := P_rma_rec.cash_ccid;
        ELSE
           IF P_source_type = 'BANK_CHARGES'
           THEN
              l_ccid := P_rma_rec.bank_charges_ccid;
           ELSE
              IF P_source_type = 'REMITTANCE'
              THEN
                 l_ccid := P_rma_rec.remittance_ccid;
              ELSE
                 IF P_source_type = 'SHORT_TERM_DEBT'
                 THEN
                    l_ccid := P_rma_rec.short_term_debt_ccid;
                 ELSE
                    IF P_source_type = 'FACTOR'
                    THEN
                       l_ccid := P_rma_rec.factor_ccid;
                    ELSE
                       IF P_source_type = 'CONFIRMATION'
                       THEN
                          l_ccid := P_rma_rec.receipt_clearing_ccid;
                       END IF;
                    END IF;
                 END IF;
              END IF;
           END IF;
        END IF;
     END IF;
   --
   P_ccid := l_ccid;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( '<<<<<<< arp_cr_util.get_dist_ccid' );
   END IF;
   --
EXCEPTION
     WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug( 'EXCEPTION arp_cr_util.get_dist_ccid' );
          END IF;
          RAISE;
END get_dist_ccid;
--
--
--
PROCEDURE get_creation_info( P_receipt_method_id    IN ar_cash_receipts.receipt_method_id%TYPE,
                         P_remit_bank_account_id    IN ar_cash_receipts.remit_bank_acct_use_id%type,
                         P_history_status OUT NOCOPY ar_cash_receipt_history.status%TYPE,
                         P_source_type OUT NOCOPY ar_distributions.source_type%TYPE,
			 P_ccid OUT NOCOPY ar_distributions.code_combination_id%TYPE,
			 P_override_remit_account_flag OUT NOCOPY ar_cash_receipts.override_remit_account_flag%TYPE) IS
l_history_status ar_cash_receipt_history.status%TYPE;
l_source_type ar_distributions.source_type%TYPE;
l_ccid ar_distributions.code_combination_id%TYPE;
l_override_remit_account_flag ar_cash_receipts.override_remit_account_flag%TYPE;
--
BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( '<<<<<<< arp_cr_util.get_creation_info' );
   END IF;
   --
   SELECT rc.creation_status,
          decode( rc.creation_status,
 		  'APPROVED', null,
		  'CONFIRMED','CONFIRMATION',
		  'REMITTED', 'REMITTANCE',
                  'CLEARED', 'CASH' ),
          decode(rc.creation_status,
			'APPROVED',null,
			'CONFIRMED', rma.receipt_clearing_ccid,
			'REMITTED',  rma.remittance_ccid,
			'CLEARED', rma.cash_ccid),
          nvl(rma.override_remit_account_flag,'Y')
   INTO   l_history_status,
	  l_source_type,
	  l_ccid,
          l_override_remit_account_flag
   FROM   ar_receipt_classes rc,
          ar_receipt_methods rm,
          ar_receipt_method_accounts rma
   WHERE  rm.receipt_class_id = rc.receipt_class_id
   AND    rm.receipt_method_id = p_receipt_method_id
   AND    rma.receipt_method_id = rm.receipt_method_id
   AND    rma.remit_bank_acct_use_id = P_remit_bank_account_id;
   --
   P_history_status := l_history_status;
   P_source_type := l_source_type;
   P_ccid := l_ccid;
   P_override_remit_account_flag := l_override_remit_account_flag;
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( '<<<<<<< arp_cr_util.get_creation_info' );
   END IF;
   --

EXCEPTION
     WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug( 'EXCEPTION arp_cr_util.get_creation_info' );
          END IF;
          RAISE;
END get_creation_info;
--


PROCEDURE get_batch_id( p_cr_id IN ar_cash_receipts.cash_receipt_id%TYPE,
		  	p_batch_id OUT NOCOPY ar_batches.batch_id%TYPE) IS
--
BEGIN
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_cr_util.get_batch_id()+' );
   END IF;
   --
   -- We select 'max' this is because if returns NULL, we do not
   -- want it to raise a return null exception.
   -- Note: there's only one record per cash receipt in history table has
   -- first_postable_flag ='Y'
   --
   SELECT max(crh.batch_id)
   INTO   p_batch_id
   FROM   ar_cash_receipt_history crh,
          ar_batches bat
   WHERE  crh.cash_receipt_id = p_cr_id
   AND    crh.first_posted_record_flag = 'Y'
   AND    bat.batch_id = crh.batch_id
   AND    bat.type = 'MANUAL';
   --
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_cr_util.get_batch_id()-' );
   END IF;
   --
EXCEPTION
     WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug( 'EXCEPTION arp_cr_util.get_batch_id' );
          END IF;
          RAISE;
END get_batch_id;

END ARP_CR_UTIL;

/
