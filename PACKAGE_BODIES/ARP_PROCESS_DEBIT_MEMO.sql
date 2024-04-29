--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_DEBIT_MEMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_DEBIT_MEMO" AS
/* $Header: ARTEDBMB.pls 115.3 2002/11/18 22:34:37 anukumar ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    line_post_insert                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Line post-insert logic for debit memo reversals.                       |
 |                                                                           |
 |    This procedure creates two distribution records that correspond to the |
 |    two sets of ccid / amount pairs that are passed in as parameters.      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_ccid1                                                |
 |                    p_ccid2                                                |
 |                    p_amount1                                              |
 |                    p_amount2                                              |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-AUG-95  Charlie Tomberg     Created                                |
 |     19-OCT-01  Muthuraman. R       Bugfix 2061395. Ora 1476 divide by zero|
 |				      occurs when receipt amount is zero.    |
 |				      This was because of percentage         |
 |				      calculation using zero. Handled in code|
 |				      now so that it becomes 100 if Amt is 0.|
 |                                                                           |
 +===========================================================================*/

PROCEDURE line_post_insert (
                            p_customer_trx_line_id   IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                            p_ccid1                  IN
                              gl_code_combinations.code_combination_id%type,
                            p_ccid2                  IN
                              gl_code_combinations.code_combination_id%type,
                            p_amount1                IN
                              ra_cust_trx_line_gl_dist.amount%type,
                            p_amount2                IN
                              ra_cust_trx_line_gl_dist.amount%type )
         IS

  l_dist_rec           ra_cust_trx_line_gl_dist%rowtype;
  l_cust_trx_line_gl_dist_id
                       ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;
  l_customer_trx_id    ra_customer_trx.customer_trx_id%type;
  l_gl_date            ra_cust_trx_line_gl_dist.gl_date%type;
  l_extended_amount    ra_customer_trx_lines.extended_amount%type;
  l_exchange_rate      ra_customer_trx.exchange_rate%type;

BEGIN

   arp_util.debug('arp_process_debit_memo.line_post_insert()+');


  /*----------------------------------------+
   |  Get information about the debit memo  |
   +----------------------------------------*/

   SELECT ct.customer_trx_id,
          ct.exchange_rate,
          lgd.gl_date,
          ctl.extended_amount
   INTO   l_customer_trx_id,
          l_exchange_rate,
          l_gl_date,
          l_extended_amount
   FROM   ra_customer_trx           ct,
          ra_cust_trx_line_gl_dist  lgd,
          ra_customer_trx_lines     ctl
   WHERE  ctl.customer_trx_line_id  = p_customer_trx_line_id
   AND    ctl.customer_trx_id       = ct.customer_trx_id
   AND    ctl.customer_trx_id       = lgd.customer_trx_id
   AND    lgd.account_class         = 'REC'
   AND    lgd.latest_rec_flag       = 'Y';


   arp_util.debug('l_customer_trx_id    = ' || l_customer_trx_id );
   arp_util.debug('l_exchange_rate      = ' || l_exchange_rate );
   arp_util.debug('l_gl_date            = ' || l_gl_date );
   arp_util.debug('l_extended_amount    = ' || l_extended_amount );
   arp_util.debug('p_amount1		= ' || p_amount1);
   arp_util.debug('p_amount2		= ' || p_amount2);
   arp_util.debug('p_ccid1		= ' || p_ccid1);
   arp_util.debug('p_ccid2		= ' || p_ccid2);

  /*-----------------------------------------------+
   |  Validate the parameters and make sure that   |
   |  the amounts add up to the extended amount.   |
   +-----------------------------------------------*/

   IF  (
          p_customer_trx_line_id  IS NULL   OR
          p_ccid1                 IS NULL   OR
          p_amount1               IS NULL   OR
          p_amount1 + p_amount2   <> l_extended_amount
       )
   THEN
         arp_util.debug('invalid parameters specified for line_post_insert()');
         fnd_message.set_name('AR', 'AR_INV_ARGS');
         fnd_message.set_token('USER_EXIT',
                               'arp_process_debit_memo.line_post_insert()');
         app_exception.raise_exception;
   END IF;


  /*-------------------------------------+
   |  Populate the distributions record  |
   +-------------------------------------*/

   l_dist_rec.customer_trx_line_id := p_customer_trx_line_id;
   l_dist_rec.customer_trx_id      := l_customer_trx_id;
   l_dist_rec.posting_control_id   := -3;
   l_dist_rec.gl_date              := l_gl_date;
   l_dist_rec.account_class        := 'REV';
   l_dist_rec.account_set_flag     := 'N';

   l_dist_rec.code_combination_id  := p_ccid1;
   l_dist_rec.amount               := p_amount1;

   /*   Bugfix 2061395. Added the following IF clause */
   IF l_extended_amount <> 0 THEN
      l_dist_rec.percent              := ROUND(
                                              ( p_amount1 * 100 ) /
                                              l_extended_amount,
                                              4
                                              );
   ELSE
      l_dist_rec.percent              := 100;
   END IF;

  /*----------------------------------+
   |  Insert distribution number one  |
   +----------------------------------*/

   arp_ctlgd_pkg.insert_p(
                           l_dist_rec,
                           l_cust_trx_line_gl_dist_id,
                           l_exchange_rate,
                           arp_trx_global.system_info.base_currency,
                           arp_trx_global.system_info.base_precision,
                           arp_trx_global.system_info.base_min_acc_unit
                         );


   arp_util.debug('ctlid for dist one: ' || l_cust_trx_line_gl_dist_id );

   IF (p_ccid2 IS NOT NULL AND
       p_amount2 IS NOT NULL) THEN

     l_dist_rec.code_combination_id  := p_ccid2;
     l_dist_rec.amount               := p_amount2;
     l_dist_rec.percent              := ROUND(
                                             ( p_amount2 * 100 ) /
                                             l_extended_amount,
                                             4
                                           );

    /*----------------------------------+
     |  Insert distribution number two  |
     +----------------------------------*/

     arp_ctlgd_pkg.insert_p(
                           l_dist_rec,
                           l_cust_trx_line_gl_dist_id,
                           l_exchange_rate,
                           arp_trx_global.system_info.base_currency,
                           arp_trx_global.system_info.base_precision,
                           arp_trx_global.system_info.base_min_acc_unit
                         );

     arp_util.debug('ctlid for dist two: ' || l_cust_trx_line_gl_dist_id );

   ELSE

     arp_util.debug('p_ccid2 or p_amount2 NULL');
     arp_util.debug('--> No 2nd distribution record needed');

   END IF;

   arp_util.debug('arp_process_debit_memo.line_post_insert()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_debit_memo.line_post_insert()');

     arp_util.debug('---------- ' ||
                 'Parameters for arp_process_debit_memo.line_post_insert() ' ||
                       '---------- ');

     arp_util.debug('p_customer_trx_line_id   = ' || p_customer_trx_line_id );
     arp_util.debug('p_ccid1                  = ' || p_ccid1 );
     arp_util.debug('p_ccid2                  = ' || p_ccid2 );
     arp_util.debug('p_amount1                = ' || p_amount1 );
     arp_util.debug('p_amount2                 = ' || p_amount2 );

     RAISE;

END;


END ARP_PROCESS_DEBIT_MEMO;

/
