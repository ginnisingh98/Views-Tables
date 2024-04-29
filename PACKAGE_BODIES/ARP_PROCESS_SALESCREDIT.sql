--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_SALESCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_SALESCREDIT" AS
/* $Header: ARTETLSB.pls 120.9 2005/09/06 20:18:02 mraymond arrt008.sql $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

pg_number_dummy number;

/* Bug 3607146 */
pg_base_precision            fnd_currencies.precision%type;
pg_base_min_acc_unit         fnd_currencies.minimum_accountable_unit%type;
pg_trx_header_level_rounding ar_system_parameters.trx_header_level_rounding%type;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_insert_salescredit		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation necessary when a new salescredit is inserted.	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_srep_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE val_insert_salescredit ( p_srep_rec IN
                                        ra_cust_trx_line_salesreps%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_salescredit.val_insert_salescredit()+');


   arp_util.debug('arp_process_salescredit.val_val_insert_salescredit()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug(
               'EXCEPTION:  arp_process_salescredit.val_insert_salescredit()');

        arp_util.debug('');
        arp_util.debug('---------- val_insert_salescredit() ---------');
        arp_util.debug('');
        arp_ctls_pkg.display_salescredit_rec(p_srep_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_update_salescredit		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a salescredit is updated.	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |	  	      p_srep_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE val_update_salescredit ( p_srep_rec IN
                                        ra_cust_trx_line_salesreps%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_salescredit.val_update_salescredit()+');


   arp_util.debug('arp_process_salescredit.val_val_update_salescredit()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug(
               'EXCEPTION:  arp_process_salescredit.val_update_salescredit()');


        arp_util.debug('');
        arp_util.debug('---------- val_update_salescredit() ---------');
        arp_util.debug('');
        arp_ctls_pkg.display_salescredit_rec(p_srep_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_delete_salescredit		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a salescredit is deleted.	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |	  	      p_srep_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE val_delete_salescredit ( p_srep_rec IN
                                        ra_cust_trx_line_salesreps%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_salescredit.val_delete_salescredit()+');


   arp_util.debug('arp_process_salescredit.val_delete_salescredit()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug(
               'EXCEPTION:  arp_process_salescredit.val_delete_salescredit()');


        arp_util.debug('');
        arp_util.debug('---------- val_update_salescredit() ---------');
        arp_util.debug('');
        arp_ctls_pkg.display_salescredit_rec(p_srep_rec);

       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_flags								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets various change and status flags for the current record.  	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 | 		     p_cust_trx_line_salesrep_id			     |
 |		     p_new_srep_rec 					     |
 |                   p_backout_flag                                          |
 |                   p_delete_flag                                           |
 |              OUT:                                                         |
 |		     p_posted_flag 					     |
 |		     p_salesrep_changed_flag  				     |
 |		     p_amount_percent_changed_flag 			     |
 |		     p_rev_amt_percent_changed_flag 			     |
 |                   p_default_record_flag                                   |
 |                   p_revised_backout_flag                                  |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_flags(p_cust_trx_line_salesrep_id IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
                    p_new_srep_rec       IN ra_cust_trx_line_salesreps%rowtype,
                    p_backout_flag                   IN boolean,
                    p_delete_flag                    IN boolean,
                    p_posted_flag                   OUT NOCOPY boolean,
                    p_salesrep_changed_flag         OUT NOCOPY boolean,
                    p_amount_percent_changed_flag   OUT NOCOPY boolean,
                    p_rev_amt_percent_changed_flag  OUT NOCOPY boolean,
                    p_default_record_flag           OUT NOCOPY boolean,
                    p_revised_backout_flag          OUT NOCOPY boolean) IS

  l_old_srep_rec  		  ra_cust_trx_line_salesreps%rowtype;
  l_posted_flag                   boolean;
  l_salesrep_changed_flag         boolean;
  l_amount_percent_changed_flag   boolean;
  l_rev_amt_percent_changed_flag  boolean;
  l_default_record_flag           boolean;
  l_revised_backout_flag          boolean;

BEGIN

   arp_util.debug('arp_process_salescredit.set_flags()+');

   arp_ctls_pkg.fetch_p(l_old_srep_rec,
                        p_cust_trx_line_salesrep_id);

   IF (l_old_srep_rec.customer_trx_line_id IS NULL )
   THEN  l_default_record_flag := TRUE;
   ELSE  l_default_record_flag := FALSE;
   END IF;

   IF     (
             l_old_srep_rec.salesrep_id <> p_new_srep_rec.salesrep_id AND
             p_new_srep_rec.salesrep_id <> pg_number_dummy
          )
   THEN   l_salesrep_changed_flag := TRUE;
   ELSE   l_salesrep_changed_flag := FALSE;
   END IF;

   IF     (
            (
               nvl(l_old_srep_rec.revenue_amount_split, 0) <>
                   nvl(p_new_srep_rec.revenue_amount_split, 0)  AND
               p_new_srep_rec.revenue_amount_split <> pg_number_dummy
            ) OR
            (
               nvl(l_old_srep_rec.revenue_percent_split, 0) <>
                   nvl(p_new_srep_rec.revenue_percent_split, 0) AND
               p_new_srep_rec.revenue_percent_split <> pg_number_dummy
            ) OR
            (
               nvl(l_old_srep_rec.non_revenue_amount_split, 0) <>
                   nvl(p_new_srep_rec.non_revenue_amount_split, 0)  AND
               p_new_srep_rec.non_revenue_amount_split <> pg_number_dummy
            ) OR
            (
               nvl(l_old_srep_rec.non_revenue_percent_split, 0) <>
                   nvl(p_new_srep_rec.non_revenue_percent_split, 0)  AND
               p_new_srep_rec.non_revenue_percent_split <> pg_number_dummy
            )
          )
   THEN  l_amount_percent_changed_flag := TRUE;
   ELSE  l_amount_percent_changed_flag := FALSE;
   END IF;

   IF     (
            (
               nvl(l_old_srep_rec.revenue_amount_split, 0) <>
                   nvl(p_new_srep_rec.revenue_amount_split, 0)  AND
               p_new_srep_rec.revenue_amount_split <> pg_number_dummy
            ) OR
            (
               nvl(l_old_srep_rec.revenue_percent_split, 0) <>
                   nvl(p_new_srep_rec.revenue_percent_split, 0) AND
               p_new_srep_rec.revenue_percent_split <> pg_number_dummy
            )
          )
   THEN  l_rev_amt_percent_changed_flag := TRUE;
   ELSE  l_rev_amt_percent_changed_flag := FALSE;
   END IF;

   arp_trx_util.set_posted_flag(l_old_srep_rec.customer_trx_id,
                                l_posted_flag);

  /*------------------------------------------------------------------+
   |  Set the backout flag to true if the transaction has been posted |
   |  and the amounts or the salesrep name has changed.               |
   +------------------------------------------------------------------*/

   IF  ( l_posted_flag          = TRUE   AND
         l_default_record_flag  = FALSE  AND
         (
           l_salesrep_changed_flag        = TRUE OR
           l_amount_percent_changed_flag  = TRUE OR
           p_delete_flag                  = TRUE
          )
        )
   THEN l_revised_backout_flag := TRUE;
        arp_util.debug('revised backout flag: TRUE');
   ELSE
        IF    ( l_default_record_flag = FALSE )
        THEN  l_revised_backout_flag := p_backout_flag;
        ELSE  l_revised_backout_flag := FALSE;
        END IF;

        arp_util.debug('revised backout flag: ' ||
                    arp_trx_util.boolean_to_varchar2(l_revised_backout_flag ));

   END IF;


   p_posted_flag	           := l_posted_flag;
   p_salesrep_changed_flag	   := l_salesrep_changed_flag;
   p_amount_percent_changed_flag   := l_amount_percent_changed_flag;
   p_rev_amt_percent_changed_flag  := l_rev_amt_percent_changed_flag;
   p_default_record_flag           := l_default_record_flag;
   p_revised_backout_flag          := l_revised_backout_flag;

   arp_util.debug('p_posted_flag                   = ' ||
                  arp_trx_util.boolean_to_varchar2(l_posted_flag));

   arp_util.debug('p_salesrep_changed_flag         = ' ||
                 arp_trx_util.boolean_to_varchar2( l_salesrep_changed_flag));

   arp_util.debug('p_amount_percent_changed_flag   = ' ||
                  arp_trx_util.boolean_to_varchar2(
                                         l_amount_percent_changed_flag));

   arp_util.debug('p_rev_amt_percent_changed_flag  = ' ||
                  arp_trx_util.boolean_to_varchar2(
                                         l_rev_amt_percent_changed_flag));

   arp_util.debug('p_default_record_flag           = ' ||
                  arp_trx_util.boolean_to_varchar2(
                                         l_default_record_flag));

   arp_util.debug('p_revised_backout_flag          = ' ||
                  arp_trx_util.boolean_to_varchar2(
                                         l_revised_backout_flag));

   arp_util.debug('arp_process_salescredit.set_flags()-');

EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_process_salescredit.set_flags()');

   arp_util.debug('');
   arp_util.debug('---------- parameters for set_flags() ---------');

   arp_util.debug('p_cust_trx_line_salesrep_id = ' ||
                  p_cust_trx_line_salesrep_id);

   arp_util.debug('p_backout_flag              = ' ||
                  arp_trx_util.boolean_to_varchar2(p_backout_flag));

   arp_util.debug('p_delete_flag               = ' ||
                  arp_trx_util.boolean_to_varchar2(p_delete_flag));

   arp_util.debug('');

   arp_util.debug('---------- new salescredit record ----------');
   arp_ctls_pkg.display_salescredit_rec( p_new_srep_rec );
   arp_util.debug('');

   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    run_autoacc_for_scredits						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets various change and status flags for the current record.  	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 | 		     p_customer_trx_id					     |
 |		     p_customer_trx_line_id				     |
 |                   p_cust_trx_line_salesrep_id                             |
 |              OUT:                                                         |
 |                   p_status		                                     |
 |          IN/ OUT:							     |
 |                   None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     02-OCT-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE run_autoacc_for_scredits( p_customer_trx_id IN
                                      ra_customer_trx.customer_trx_id%type,
                                    p_customer_trx_line_id IN
                            ra_customer_trx_lines.customer_trx_line_id%type,
                                    p_cust_trx_line_salesrep_id IN
                  ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type
                  DEFAULT NULL,
                                    p_status  OUT NOCOPY varchar2 ) IS

   l_concat_segments       ra_cust_trx_line_gl_dist.concatenated_segments%type;
   l_ccid                  ra_cust_trx_line_gl_dist.code_combination_id%type;
   l_result                number;
   l_num_failed_dist_rows  number;
   l_errorbuf              varchar2(200);

   /* bug 3607146 */
   l_error_message VARCHAR2(128) := '';
   l_dist_count NUMBER;

BEGIN

   arp_util.debug('arp_process_salescredit.run_autoacc_for_scredits()+');

   arp_util.debug('p_customer_trx_id            = ' ||
                   to_char( p_customer_trx_id ));
   arp_util.debug('p_customer_trx_line_id       = ' ||
                   to_char( p_customer_trx_line_id ));
   arp_util.debug('p_cust_trx_line_salesrep_id  = ' ||
                  to_char( p_cust_trx_line_salesrep_id ));

   BEGIN

             p_status := 'OK';

             arp_auto_accounting.do_autoaccounting
                (
                   'U',
                   'REV',
                   p_customer_trx_id,
                   p_customer_trx_line_id,
                   p_cust_trx_line_salesrep_id,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   l_ccid,
                   l_concat_segments,
                   l_num_failed_dist_rows
                );
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
             arp_auto_accounting.do_autoaccounting
                (
                   'U',
                   'CHARGES',
                   p_customer_trx_id,
                   p_customer_trx_line_id,
                   p_cust_trx_line_salesrep_id,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   l_ccid,
                   l_concat_segments,
                   l_num_failed_dist_rows
                );
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
             arp_auto_accounting.do_autoaccounting
                (
                   'U',
                   'UNBILL',
                   p_customer_trx_id,
                   p_customer_trx_line_id,
                   p_cust_trx_line_salesrep_id,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   l_ccid,
                   l_concat_segments,
                   l_num_failed_dist_rows
                );
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
             arp_auto_accounting.do_autoaccounting
                (
                   'U',
                   'UNEARN',
                   p_customer_trx_id,
                   p_customer_trx_line_id,
                   p_cust_trx_line_salesrep_id,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   l_ccid,
                   l_concat_segments,
                   l_num_failed_dist_rows
                );
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
             arp_auto_accounting.do_autoaccounting
                (
                   'U',
                   'SUSPENSE',
                   p_customer_trx_id,
                   p_customer_trx_line_id,
                   p_cust_trx_line_salesrep_id,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   l_ccid,
                   l_concat_segments,
                   l_num_failed_dist_rows
                );
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   BEGIN
             arp_auto_accounting.do_autoaccounting
                (
                   'U',
                   'TAX',
                   p_customer_trx_id,
                   p_customer_trx_line_id,
                   p_cust_trx_line_salesrep_id,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   null,
                   l_ccid,
                   l_concat_segments,
                   l_num_failed_dist_rows
                );
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status := 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


  /*----------------------------------+
   |  Raise AutoAccounting exception  |
   +----------------------------------*/

   IF   (l_errorbuf is not null)
   THEN   arp_util.debug('AutoAccounting error: ' || l_errorbuf);

          FND_MESSAGE.set_name('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.set_token( 'GENERIC_TEXT',  l_errorbuf);
          APP_EXCEPTION.raise_exception;

   END IF;

   /* bug 3607146 */
   IF  arp_rounding.correct_dist_rounding_errors(
                                        NULL,
                                        p_customer_trx_id,
                                        p_customer_trx_line_id ,
                                        l_dist_count,
                                        l_error_message ,
                                        pg_base_precision ,
                                        pg_base_min_acc_unit ,
                                        'ALL' ,
                                        'N' ,
                                        'N' ,
                                        pg_trx_header_level_rounding ,
                                        'N',
                                        'N') = 0 -- FALSE
    THEN
        arp_util.debug('EXCEPTION: arp_process_salescredit.run_autoacc_for_scredits');
        arp_util.debug(l_error_message);
        fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');
        APP_EXCEPTION.raise_exception;
    END IF;

   arp_util.debug('arp_process_salescredit.run_autoacc_for_scredits()-');

EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug(
              'EXCEPTION:  arp_process_salescredit.run_autoacc_for_scredits');

   IF   (l_errorbuf is not null)
   THEN arp_util.debug('AutoAccounting error: ' || l_errorbuf);
   END IF;

   arp_util.debug('');
   arp_util.debug('---------- parameters for run_autoacc_for_scredits () ' ||
                  '---------');

   arp_util.debug('p_customer_trx_id       = ' || TO_CHAR( p_customer_trx_id));
   arp_util.debug('p_customer_trx_line_id  = ' ||
                  TO_CHAR( p_customer_trx_line_id));
   arp_util.debug('p_cust_trx_line_salesrep_id  = ' ||
                  TO_CHAR( p_cust_trx_line_salesrep_id));

   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    backout_salesrep							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts two records to backout the existing salescredit record.	     |
 |    This procedure is called if backout is required and the salescredit's  |
 |    salesrep name or number has changed.			     	     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_old_srep_rec                                         |
 |                    p_new_srep_rec                                         |
 |                    p_run_auto_accounting_flag                             |
 |              OUT:                                                         |
 |                    p_status						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE backout_salesrep(
                         p_old_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                         p_new_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                         p_run_auto_accounting_flag  IN boolean,
                         p_status                   OUT NOCOPY varchar2 )
                          IS

   l_cust_trx_line_salesrep_id
                   ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;

   l_old_srep_rec ra_cust_trx_line_salesreps%rowtype;
   l_new_srep_rec ra_cust_trx_line_salesreps%rowtype;

   l_status1  varchar2(100);
   l_status2  varchar2(100);

BEGIN

   arp_util.debug('arp_process_salescredit.backout_salesrep()+');

   l_old_srep_rec := p_old_srep_rec;
   l_new_srep_rec := p_new_srep_rec;


   /*--------------------------+
    |    insert the new row    |
    +--------------------------*/


   /*---------------------------------------------------------------+
    |    If a new value was specified in the srep rec passed into   |
    |    update_salescredit(). use that value. Otherwise, use the   |
    |    value from the original salescredit line.                  |
    +---------------------------------------------------------------*/

  arp_ctls_pkg.merge_srep_recs(l_old_srep_rec,
                               l_new_srep_rec,
                               l_new_srep_rec);

   /*-------------------------------------------------------------+
    |    Call the table handler to insert the new salesrep record |
    +-------------------------------------------------------------*/

   arp_ctls_pkg.insert_p( l_new_srep_rec,
                          l_cust_trx_line_salesrep_id);

   IF ( p_run_auto_accounting_flag = TRUE )
   THEN
        run_autoacc_for_scredits( l_new_srep_rec.customer_trx_id,
                                  l_new_srep_rec.customer_trx_line_id,
                                  l_cust_trx_line_salesrep_id,
                                  l_status1 );
   END IF;

   /*--------------------------------------------+
    |    backout the original salescredit row    |
    +--------------------------------------------*/

   l_old_srep_rec.revenue_amount_split :=
                      -1 * l_old_srep_rec.revenue_amount_split;

   l_old_srep_rec.revenue_percent_split :=
                      -1 * l_old_srep_rec.revenue_percent_split;

   l_old_srep_rec.non_revenue_amount_split :=
                   -1 * l_old_srep_rec.non_revenue_amount_split;

   l_old_srep_rec.non_revenue_percent_split :=
                   -1 * l_old_srep_rec.non_revenue_percent_split;

   arp_ctls_pkg.insert_p( l_old_srep_rec,
                          l_cust_trx_line_salesrep_id);

   IF ( p_run_auto_accounting_flag = TRUE )
   THEN
        run_autoacc_for_scredits( l_new_srep_rec.customer_trx_id,
                                  l_new_srep_rec.customer_trx_line_id,
                                  l_cust_trx_line_salesrep_id,
                                  l_status2 );
   END IF;

   arp_util.debug('l_status1  = ' || l_status1);
   arp_util.debug('l_status2  = ' || l_status2);

   IF ( NVL(l_status1, 'OK') <> 'OK')
   THEN  p_status := l_status1;
   ELSE  IF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN p_status := l_status2;
         ELSE p_status := 'OK';
         END IF;
   END IF;

   arp_util.debug('arp_process_salescredit.backout_salesrep()-');

EXCEPTION
  WHEN OTHERS THEN
      arp_util.debug('EXCEPTION:  arp_process_salescredit.backout_salesrep()');
      RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    backout_amount							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts one record to backout the existing salescredit record.	     |
 |    This procedure is called if backout is required and the amount or      |
 |    percent of a salescredit record has changed.			     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_old_srep_rec                                         |
 |                    p_new_srep_rec                                         |
 |                    p_run_auto_accounting_flag                             |
 |              OUT:                                                         |
 |                    p_status						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE backout_amount(
                          p_old_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                          p_new_srep_rec IN ra_cust_trx_line_salesreps%rowtype,
                          p_run_auto_accounting_flag  IN boolean,
                          p_status                   OUT NOCOPY varchar2 )
                          IS

   l_cust_trx_line_salesrep_id
                   ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;

   l_old_srep_rec ra_cust_trx_line_salesreps%rowtype;
   l_new_srep_rec ra_cust_trx_line_salesreps%rowtype;

BEGIN

   arp_util.debug('arp_process_salescredit.backout_amount()+');

   l_old_srep_rec := p_old_srep_rec;
   l_new_srep_rec := p_new_srep_rec;

   /*---------------------------------------------------------------+
    |    create an offsetting record  to preserve the audit trail   |
    +---------------------------------------------------------------*/


   l_new_srep_rec.revenue_amount_split :=
                    l_new_srep_rec.revenue_amount_split -
                    l_old_srep_rec.revenue_amount_split;

   l_new_srep_rec.revenue_percent_split :=
                    l_new_srep_rec.revenue_percent_split -
                    l_old_srep_rec.revenue_percent_split;

   l_new_srep_rec.non_revenue_amount_split :=
                    NVL(l_new_srep_rec.non_revenue_amount_split, 0) -
                    NVL(l_old_srep_rec.non_revenue_amount_split, 0);

   l_new_srep_rec.non_revenue_percent_split :=
                    NVL(l_new_srep_rec.non_revenue_percent_split, 0) -
                    NVL(l_old_srep_rec.non_revenue_percent_split, 0);


   /*---------------------------------------------------------------+
    |    If a new value was specified in the srep rec passed into   |
    |    update_salescredit(). use that value. Otherwise, use the   |
    |    value from the original salescredit line.                  |
    +---------------------------------------------------------------*/

   arp_ctls_pkg.merge_srep_recs(l_old_srep_rec,
                                l_new_srep_rec,
                                l_old_srep_rec);

   arp_ctls_pkg.insert_p( l_old_srep_rec,
                          l_cust_trx_line_salesrep_id);

   IF ( p_run_auto_accounting_flag = TRUE )
   THEN
        run_autoacc_for_scredits( l_new_srep_rec.customer_trx_id,
                                  l_new_srep_rec.customer_trx_line_id,
                                  l_cust_trx_line_salesrep_id,
                                  p_status );
   END IF;

   arp_util.debug('arp_process_salescredit.backout_amount()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_process_salescredit.backout_amount()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_tax_from_revenue		               		             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    If Autoaccounting is rerun due to a change in the Sales Credit,        |
 |    Validate Revenue Account tax code is used at the Transaction line      |
 |    if the system option Enforces tax code from GL for a Completed         |
 |    transaction. Validation will be performed during completion for        |
 |    incomplete transactions.                                               |
 |                                                                           |
 |    Perform this validation if the transaction is set to complete for      |
 |    On-Account Credit Memos, Debit Memos and Invoices only.                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_process_tax.validate_tax_enforcement                               |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id   				     |
 |                    p_customer_trx_line_id				     |
 |                    p_run_auto_accounting_flag			     |
 |              OUT:                                                         |
 |                    p_status                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     02-Oct-97  Mahesh Sabapathy    Created                                |
 |     06-SEP-05  M Raymond           Obsolete by etax.
 +===========================================================================*/


PROCEDURE val_tax_from_revenue (
	p_customer_trx_id 	   IN ra_customer_trx.customer_trx_id%type,
	p_customer_trx_line_id 	   IN ra_customer_trx_lines.customer_trx_line_id%type,
	p_run_auto_accounting_flag IN BOOLEAN,
	p_status 		   OUT NOCOPY VARCHAR2 ) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_salescredit.val_tax_from_revenue()+');
   END IF;

   p_status := 'OK';

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_salescredit.val_tax_from_revenue()-');
   END IF;

END val_tax_from_revenue;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_salescredit						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_cust_trx_line_salesreps			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_run_auto_accounting_flag			     |
 |		      p_srep_rec					     |
 |		      p_cust_trx_line_salesrep_id 			     |
 |              OUT:                                                         |
 |                    p_status						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE insert_salescredit(
           p_form_name                IN varchar2,
           p_form_version             IN number,
           p_run_auto_accounting_flag IN boolean,
           p_srep_rec		      IN ra_cust_trx_line_salesreps%rowtype,
           p_cust_trx_line_salesrep_id  OUT NOCOPY
               ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_status                     OUT NOCOPY varchar2)
                   IS


   l_cust_trx_line_salesrep_id
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;
   l_status1		VARCHAR2(100);
   l_status2		VARCHAR2(100);

BEGIN

      arp_util.debug('arp_process_salescredit.insert_salescredit()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_salescredit.val_insert_salescredit(p_srep_rec);

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_srep_rec.customer_trx_id);


      arp_ctls_pkg.insert_p( p_srep_rec,
                             l_cust_trx_line_salesrep_id);

      p_cust_trx_line_salesrep_id := l_cust_trx_line_salesrep_id;


     /*----------------------------------------------------------------+
      | Rerun AutoAccounting if the p_run_auto_accounting_flag = TRUE  |
      +----------------------------------------------------------------*/

      IF   ( p_run_auto_accounting_flag = TRUE )
      THEN

            run_autoacc_for_scredits( p_srep_rec.customer_trx_id,
                                      p_srep_rec.customer_trx_line_id,
                                      l_cust_trx_line_salesrep_id,
                                      l_status1 );

      END IF;


      /*----------------------------------------------------------------+
       | Validate Tax from Revenue Account if Auto Accounting was rerun |
       +----------------------------------------------------------------*/

      IF   ( p_run_auto_accounting_flag = TRUE ) THEN

            val_tax_from_revenue( p_srep_rec.customer_trx_id,
                                  p_srep_rec.customer_trx_line_id,
                                  p_run_auto_accounting_flag,
                                  l_status2 );

      END IF;

      arp_util.debug('l_status1  = ' || l_status1);
      arp_util.debug('l_status2  = ' || l_status2);

      IF    ( NVL(l_status1, 'OK') <> 'OK' )
      THEN  p_status := l_status1;
      ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN  p_status := l_status2;
      ELSE     p_status := 'OK';
      END IF;


      arp_util.debug('arp_process_salescredit.insert_salescredit()-');

EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug('EXCEPTION:  arp_process_salescredit.insert_salescredit()');

   /*---------------------------------------------+
    |  Display parameters and raise the exception |
    +---------------------------------------------*/

    arp_util.debug('EXCEPTION:  arp_process_salescredit.insert_salescredit()');

    arp_util.debug('');
    arp_util.debug('---------- insert_salescredit() ---------');

    arp_util.debug('p_form_name                = ' || p_form_name);
    arp_util.debug('p_form_version             = ' || p_form_version);

    arp_util.debug('p_run_auto_accounting_flag = ' ||
                 arp_trx_util.boolean_to_varchar2(p_run_auto_accounting_flag));

    arp_util.debug('');
    arp_ctls_pkg.display_salescredit_rec( p_srep_rec );
    arp_util.debug('');

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_salescredit						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a record in ra_cust_trx_line_salesreps			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_run_auto_accounting_flag 			     |
 |		      p_backout_flag 					     |
 |		      p_posted_flag 					     |
 |		      p_salesrep_changed_flag 				     |
 |		      p_amount_percent_changed_flag			     |
 |		      p_cust_trx_line_salesrep_id  			     |
 |		      p_customer_trx_id		  			     |
 |		      p_srep_rec					     |
 |              OUT:                                                         |
 |                    p_backout_done_flag                                    |
 |		      p_status						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_salescredit(
           p_form_name                   IN varchar2,
           p_form_version                IN number,
           p_run_auto_accounting_flag    IN boolean,
           p_backout_flag                IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id		 IN
                     ra_customer_trx.customer_trx_id%type,
           p_customer_trx_line_id	 IN
                     ra_customer_trx_lines.customer_trx_line_id%type,
           p_srep_rec		         IN ra_cust_trx_line_salesreps%rowtype,
           p_backout_done_flag          OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2)
                   IS


   l_cust_trx_line_salesrep_id
                    ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;
   l_old_srep_rec                  ra_cust_trx_line_salesreps%rowtype;
   l_dist_rec                      ra_cust_trx_line_gl_dist%rowtype;
   l_backout_flag	           boolean;

   l_posted_flag       	           boolean;
   l_salesrep_changed_flag         boolean;
   l_amount_percent_changed_flag   boolean;
   l_rev_amt_percent_changed_flag  boolean;
   l_default_records_flag          boolean;
   l_status1                       varchar2(100);
   l_status2                       varchar2(100);
   l_status3                       varchar2(100);
   l_status4                       varchar2(100);

BEGIN

      arp_util.debug('arp_process_salescredit.update_salescredit()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      set_flags(p_cust_trx_line_salesrep_id,
                p_srep_rec,
                p_backout_flag,
                FALSE,             -- p_delete_flag
                l_posted_flag,
                l_salesrep_changed_flag,
                l_amount_percent_changed_flag,
                l_rev_amt_percent_changed_flag,
                l_default_records_flag,
                l_backout_flag);

      p_backout_done_flag := l_backout_flag;

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_salescredit.val_update_salescredit(p_srep_rec);

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_customer_trx_id);


	/*------------------------------------------------------+
         |  IF    backout is not required 			|
         |  THEN  do a simple update				|
         |  ELSE IF   the salesrep name has changed		|
         |       THEN create two offsetting records		|
         |       ELSE IF   the amount or percent has changed	|
         |            THEN create one ofsetting record		|
         |            ELSE do a simple update			|
	 +------------------------------------------------------*/

      IF   (l_backout_flag = FALSE)
      THEN
 	      /*--------------------------------------+
               |  Do a simple update with no backout. |
               +--------------------------------------*/

               arp_util.debug('simple update - case 1');
               arp_ctls_pkg.update_p( p_srep_rec,
                                      p_cust_trx_line_salesrep_id);

      ELSE
           arp_ctls_pkg.fetch_p(l_old_srep_rec, p_cust_trx_line_salesrep_id);


           IF  ( l_salesrep_changed_flag = TRUE)
           THEN

  	        /*------------------------------------------------+
                 |  Insert 2 rows into ra_cust_trx_line_salesreps |
                 |       1. amount = -<db amount>,		  |
                 |          ccid = <db (old) ccid>		  |
                 |       2. amount = <displayed amount>,	  |
                 |          ccid = <new salesrep>		  |
                 +------------------------------------------------*/

                backout_salesrep(l_old_srep_rec,
                                 p_srep_rec,
                                 p_run_auto_accounting_flag,
                                 l_status1  );

           ELSE IF (l_amount_percent_changed_flag = TRUE)
                THEN

    	            /*------------------------------------------------+
                     |  Insert one new row to backout the old amount. |
                     |  amount = <displayed amount> - <db amount>     |
                     +------------------------------------------------*/

                     backout_amount(l_old_srep_rec,
                                    p_srep_rec,
                                    p_run_auto_accounting_flag,
                                    l_status2  );
                ELSE

    	            /*--------------------------------------+
                     |  Do a simple update with no backout. |
                     |  Nothing of consequence has changed. |
                     +--------------------------------------*/

                     arp_util.debug('simple update - case 2');

                     arp_ctls_pkg.update_p(p_srep_rec,
                                           p_cust_trx_line_salesrep_id);
                END IF;

           END IF;
      END IF;


      IF   (
                 p_run_auto_accounting_flag = TRUE
             AND l_backout_flag = FALSE
           )
      THEN
           /*----------------------------------------------------------------+
            | Rerun AutoAccounting if the p_run_auto_accounting_flag = TRUE  |
            +----------------------------------------------------------------*/

            run_autoacc_for_scredits( p_customer_trx_id,
                                      p_customer_trx_line_id,
                                      null,
                                      l_status3 );

      ELSE

       /*-------------------------------------------------------------------+
        | If autoaccounting is based on salesreps, and the user said No to  |
        | the Rerun AutoAccounting question, then null out NOCOPY the cust_trx_    |
        | line_salesrep_id of all distributions that used to be linked to   |
        | this salesrep line.  Do this only if Salesrep name, number,       |
        |  revenue pct, or revenue amount were updated.                     |
	+-------------------------------------------------------------------*/

            IF   (
                      (
                        l_salesrep_changed_flag        = TRUE OR
                        l_rev_amt_percent_changed_flag = TRUE
                      )
                  AND l_backout_flag = FALSE
                 )
            THEN

                 arp_ctls_pkg.erase_foreign_key_references(
                                                 p_cust_trx_line_salesrep_id,
                                                 NULL,
                                                 NULL);
            END IF;

      END IF;


      /*----------------------------------------------------------------+
       | Validate Tax from Revenue Account if Auto Accounting was rerun |
       +----------------------------------------------------------------*/

      IF   ( p_run_auto_accounting_flag = TRUE ) THEN

            val_tax_from_revenue( p_customer_trx_id,
                                  p_customer_trx_line_id,
				  p_run_auto_accounting_flag,
				  l_status4 );

      END IF;


      arp_util.debug('l_status1  = ' || l_status1);
      arp_util.debug('l_status2  = ' || l_status2);
      arp_util.debug('l_status3  = ' || l_status3);
      arp_util.debug('l_status4  = ' || l_status4);

      IF    ( NVL(l_status1, 'OK') <> 'OK' )
      THEN  p_status := l_status1;
      ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN  p_status := l_status2;
      ELSIF ( NVL(l_status3, 'OK') <> 'OK' )
         THEN  p_status := l_status3;
      ELSIF ( NVL(l_status4, 'OK') <> 'OK' )
         THEN  p_status := l_status4;
      ELSE     p_status := 'OK';
      END IF;

      arp_util.debug('arp_process_salescredit.update_salescredit()-');

EXCEPTION
  WHEN OTHERS THEN


  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

    arp_util.debug('EXCEPTION:  arp_process_salescredit.update_salescredit()');
    arp_util.debug('');
    arp_util.debug('---------- parameters for update_salescredit() ---------');
    arp_util.debug('p_form_name                 = ' || p_form_name);
    arp_util.debug('p_form_version              = ' || p_form_version);


    arp_util.debug('p_run_auto_accounting_flag  = ' ||
                 arp_trx_util.boolean_to_varchar2(p_run_auto_accounting_flag));

    arp_util.debug('p_backout_flag              = ' ||
                             arp_trx_util.boolean_to_varchar2(p_backout_flag));

    arp_util.debug('p_cust_trx_line_salesrep_id = ' ||
                   p_cust_trx_line_salesrep_id);
    arp_util.debug('p_customer_trx_id           = ' || p_customer_trx_id);
    arp_util.debug('p_customer_trx_line_id      = ' || p_customer_trx_line_id);

    arp_util.debug('');
    arp_ctls_pkg.display_salescredit_rec( p_srep_rec );
    arp_util.debug('');

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_salescredit						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes a record from ra_cust_trx_line_salesreps.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_run_auto_accounting_flag  			     |
 |		      p_cust_trx_line_salesrep_id 			     |
 |		      p_srep_rec					     |
 |                    p_backout_flag                                         |
 |              OUT:                                                         |
 |                    p_status						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE delete_salescredit(
           p_form_name                   IN varchar2,
           p_form_version                IN number,
           p_run_auto_accounting_flag    IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id		 IN
                     ra_customer_trx.customer_trx_id%type,
           p_customer_trx_line_id	 IN
                     ra_customer_trx_lines.customer_trx_line_id%type,
           p_srep_rec		         IN ra_cust_trx_line_salesreps%rowtype,
           p_backout_flag                IN boolean DEFAULT FALSE,
           p_backout_done_flag          OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2)
                   IS

   l_backout_flag	           boolean;
   l_posted_flag       	           boolean;
   l_salesrep_changed_flag         boolean;
   l_amount_percent_changed_flag   boolean;
   l_rev_amt_percent_changed_flag  boolean;
   l_default_records_flag          boolean;
   l_old_srep_rec                  ra_cust_trx_line_salesreps%rowtype;
   l_temp_srep_rec                 ra_cust_trx_line_salesreps%rowtype;
   l_status1                       varchar2(100);
   l_status2                       varchar2(100);
   l_status3                       varchar2(100);

BEGIN

      arp_util.debug('arp_process_salescredit.delete_salescredit()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_salescredit.val_delete_salescredit(p_srep_rec);

      set_flags(p_cust_trx_line_salesrep_id,
                p_srep_rec,
                p_backout_flag,
                TRUE,           -- delete_flag
                l_posted_flag,
                l_salesrep_changed_flag,
                l_amount_percent_changed_flag,
                l_rev_amt_percent_changed_flag,
                l_default_records_flag,
                l_backout_flag);

      p_backout_done_flag := l_backout_flag;

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_customer_trx_id);


     /*---------------------------------------------------------------------+
      |  If no backout is required, do a simple delete.                     |
      |  Otherwise, create an offsetting salescredit record and optionally  |
      |    an ofsetting distribution record.                                |
      +---------------------------------------------------------------------*/

      IF   (l_backout_flag = FALSE)
      THEN

          /*-----------------------------------------------------------+
           |  call the table-handler to delete the salescredit record  |
           +-----------------------------------------------------------*/

           arp_ctls_pkg.delete_p(p_cust_trx_line_salesrep_id,
                                 p_customer_trx_line_id);

      ELSE
            arp_ctls_pkg.fetch_p(l_old_srep_rec, p_cust_trx_line_salesrep_id);

            l_temp_srep_rec                            := l_old_srep_rec;
            l_temp_srep_rec.revenue_amount_split       := 0;
            l_temp_srep_rec.revenue_percent_split      := 0;
            l_temp_srep_rec.non_revenue_amount_split   := 0;
            l_temp_srep_rec.non_revenue_percent_split  := 0;

            backout_amount(l_old_srep_rec,
                           l_temp_srep_rec,
                           p_run_auto_accounting_flag,
                           l_status1  );

      END IF;


      /*----------------------------------------------------------------+
       | Rerun AutoAccounting if the p_run_auto_accounting_flag = TRUE  |
       | and no backout was done.                                       |
       +----------------------------------------------------------------*/

      IF    (
                  p_run_auto_accounting_flag = TRUE
             AND  l_backout_flag = FALSE
            )

      THEN

            run_autoacc_for_scredits( p_customer_trx_id,
                                      p_customer_trx_line_id,
                                      NULL,
                                      l_status2 );

      END IF;

      /*----------------------------------------------------------------+
       | Validate Tax from Revenue Account if Auto Accounting was rerun |
       +----------------------------------------------------------------*/

      IF   ( p_run_auto_accounting_flag = TRUE ) THEN

            val_tax_from_revenue( p_customer_trx_id,
                                  p_customer_trx_line_id,
                                  p_run_auto_accounting_flag,
                                  l_status3 );

      END IF;

      arp_util.debug('l_status1  = ' || l_status1);
      arp_util.debug('l_status2  = ' || l_status2);
      arp_util.debug('l_status3  = ' || l_status3);

      IF    ( NVL(l_status1, 'OK') <> 'OK' )
      THEN  p_status := l_status1;
      ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
         THEN  p_status := l_status2;
      ELSIF ( NVL(l_status3, 'OK') <> 'OK' )
         THEN  p_status := l_status3;
      ELSE     p_status := 'OK';
      END IF;

      arp_util.debug('arp_process_salescredit.delete_salescredit()-');

EXCEPTION
 WHEN OTHERS THEN


   /*---------------------------------------------+
    |  Display parameters and raise the exception |
    +---------------------------------------------*/

    arp_util.debug('EXCEPTION:  arp_process_salescredit.delete_salescredit()');

    arp_util.debug('');
    arp_util.debug('---------- delete_salescredit() ---------');

    arp_util.debug('p_form_name                  = ' || p_form_name);
    arp_util.debug('p_form_version               = ' || p_form_version);

    arp_util.debug('p_cust_trx_line_salesrep_id  = ' ||
                   p_cust_trx_line_salesrep_id);
    arp_util.debug('p_customer_trx_id            = ' || p_customer_trx_id);
    arp_util.debug('p_customer_trx_line_id       = ' ||
                   p_customer_trx_line_id);

    arp_util.debug('p_run_auto_accounting_flag   = ' ||
                arp_trx_util.boolean_to_varchar2(p_run_auto_accounting_flag));

    arp_util.debug('p_backout_flag               = ' ||
                arp_trx_util.boolean_to_varchar2(p_backout_flag));

    arp_util.debug('');
    arp_ctls_pkg.display_salescredit_rec( p_srep_rec );
    arp_util.debug('');

    RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   create_line_salescredits		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates the appropriate salescredits for the transaction line.	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |                    p_customer_trx_line_id				     |
 |                    p_memo_line_type 					     |
 |                    p_delete_scredits_first_flag                           |
 |                    p_run_autoaccounting_flag                              |
 |              OUT:                                                         |
 |                    p_status                                               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-JUL-95  Charlie Tomberg     Created                                |
 |     28-NOV-95  Martin Johnson      nvl p_memo_line_type                   |
 |                                                                           |
 +===========================================================================*/


PROCEDURE create_line_salescredits(p_customer_trx_id IN
                              ra_customer_trx_lines.customer_trx_id%type,
                                   p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                                   p_memo_line_type       IN
                                                 ar_memo_lines.line_type%type,
                                   p_delete_scredits_first_flag IN
                                          varchar2,
                                   p_run_autoaccounting_flag IN varchar2,
                                   p_status   OUT NOCOPY varchar2)
                                IS

   l_status1            VARCHAR2(100);
   l_status2            VARCHAR2(100);
   prev_customer_trx_id ra_customer_trx.previous_customer_trx_id%type;
   p_salesrep_id	ra_customer_trx.primary_salesrep_id%type;

BEGIN

   arp_util.debug('arp_process_salescredit.create_line_salescredits()+');

  /*-------------------------------------+
   |Checking whether its Credit Memo     |
   +-------------------------------------*/

   SELECT previous_customer_trx_id ,
	  primary_salesrep_id
   into
	  prev_customer_trx_id,
	  p_salesrep_id
   FROM   ra_customer_trx
   WHERE  customer_trx_id = p_customer_trx_id;

  /*--------------------------------------+
   |  Charges do not have salescredits.   |
   |  If this is a charges memo line,     |
   |  then don't do any processing.       |
   +--------------------------------------*/

   IF   ( nvl(p_memo_line_type, 'x') <> 'CHARGES' )
   THEN

       /*----------------------------------------------------------------+
        | Lock rows in other tables that reference this customer_trx_id  |
        +----------------------------------------------------------------*/

       arp_trx_util.lock_transaction(p_customer_trx_id);

      /*----------------------------------------+
       |  Delete salescredits first if desired  |
       +----------------------------------------*/


       IF    ( p_delete_scredits_first_flag = 'Y' )
       THEN
             IF       ( p_customer_trx_line_id IS NOT NULL )
             THEN
                      arp_ctls_pkg.delete_f_ctl_id( p_customer_trx_line_id );
             ELSIF    ( p_customer_trx_id IS NOT NULL )
                THEN  arp_ctls_pkg.delete_f_ct_id( p_customer_trx_id, FALSE );
             END IF;

       END IF;

       /*-------------------------------------------------------+
        |  If there are no default salescredits,		|
        |  insert a single salescredit record that corresponds  |
        |  to the header salesrep. 				|
        |  Otherwise, create salescredits that correspond to 	|
        |  the header default salescredits.			|
	+-------------------------------------------------------*/

       /*-------------------------------------------------+
        |Bug 1157776 If this is a Credit Memo,            |
        |then call arp_ctls_pkg.insert_f_cmn_ct_ctl_id    |
        +-------------------------------------------------*/
        /*------------------------------------------------------------------+
         | Bug 1485133.                                                     |
         | We need to check if the RA_CUSTOMER_TRX.PRIMARY_SALESREP_ID      |
         | is not null before calling  arp_ctls_pkg.insert_f_cmn_ct_ctl_id  |
         +------------------------------------------------------------------*/

        IF (prev_customer_trx_id is not null) then

                IF (p_salesrep_id is not null) then
                        arp_ctls_pkg.insert_f_cmn_ct_ctl_id( p_customer_trx_id,
                                                                p_customer_trx_line_id );
                END IF;
        ELSE
            arp_ctls_pkg.insert_f_ct_ctl_id( p_customer_trx_id,
                                                p_customer_trx_line_id );
        END IF;

      /*----------------------------------+
       | Rerun AutoAccounting if desired  |
       +----------------------------------*/

      IF    ( p_run_autoaccounting_flag = 'Y' )
      THEN
            run_autoacc_for_scredits( p_customer_trx_id,
                                      p_customer_trx_line_id,
                                      NULL,
                                      l_status1 );

      END IF;


      /*----------------------------------------------------------------+
       | Validate Tax from Revenue Account if Auto Accounting was rerun |
       +----------------------------------------------------------------*/

      IF   ( p_run_autoaccounting_flag = 'Y' ) THEN

            val_tax_from_revenue( p_customer_trx_id,
                                  p_customer_trx_line_id,
                                  TRUE, 	-- p_run_auto_accounting_flag,
                                  l_status2 );

      END IF;


   END IF;

   arp_util.debug('l_status1  = ' || l_status1);
   arp_util.debug('l_status2  = ' || l_status2);

   IF    ( NVL(l_status1, 'OK') <> 'OK' )
   	THEN  p_status := l_status1;
   ELSIF ( NVL(l_status2, 'OK') <> 'OK' )
   	THEN  p_status := l_status2;
   ELSE     p_status := 'OK';
   END IF;

   arp_util.debug('arp_process_salescredit.create_line_salescredits()-');

EXCEPTION
    WHEN OTHERS THEN
	arp_util.debug(sqlerrm);
        arp_util.debug(
            'EXCEPTION:  arp_process_salescredit.create_line_salescredits()');


        arp_util.debug('');
        arp_util.debug('---- parameters for create_line_salescredits() -----');

        arp_util.debug('p_customer_trx_id      = ' || p_customer_trx_id);
        arp_util.debug('p_customer_trx_line_id = ' || p_customer_trx_line_id);
        arp_util.debug('p_memo_line_type       = ' || p_memo_line_type);


        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_salescredit_cover						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a salescredit record and                 |
 |    inserts a salescredit line.                                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_run_auto_accounting_flag			     |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_salesrep_id                                          |
 |                    p_revenue_amount_split                                 |
 |                    p_non_revenue_amount_split                             |
 |                    p_non_revenue_percent_split                            |
 |                    p_revenue_percent_split                                |
 |                    p_prev_cust_trx_line_srep_id                           |
 |                    p_attribute_category                                   |
 |                    p_attribute1                                           |
 |                    p_attribute2                                           |
 |                    p_attribute3                                           |
 |                    p_attribute4                                           |
 |                    p_attribute5                                           |
 |                    p_attribute6                                           |
 |                    p_attribute7                                           |
 |                    p_attribute8                                           |
 |                    p_attribute9                                           |
 |                    p_attribute10                                          |
 |                    p_attribute11                                          |
 |                    p_attribute12                                          |
 |                    p_attribute13                                          |
 |                    p_attribute14                                          |
 |                    p_attribute15                                          |
 |                    p_revenue_salesgroup_id                                |
 |                    p_non_revenue_salesgroup_id                            |
 |              OUT:                                                         |
 |		      p_cust_trx_line_salesrep_id 			     |
 |                    p_status                                               |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE insert_salescredit_cover(
           p_form_name                       IN varchar2,
           p_form_version                    IN number,
           p_run_auto_accounting_flag        IN boolean,

           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_cust_trx_line_salesrep_id  OUT NOCOPY
               ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_status                     OUT NOCOPY varchar2,
           p_revenue_salesgroup_id           IN
                    ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                    ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null)

                   IS

      l_srep_rec ra_cust_trx_line_salesreps%rowtype;

      /* bug 3607146 */
      l_scredit_count NUMBER;
BEGIN

      arp_util.debug('arp_process_salescredit.insert_salescredit_cover()+');

     /*------------------------------------------------+
      |  Populate the salescredit record group with    |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      l_srep_rec.customer_trx_id              := p_customer_trx_id;
      l_srep_rec.customer_trx_line_id         := p_customer_trx_line_id;
      l_srep_rec.salesrep_id                  := p_salesrep_id;
      l_srep_rec.revenue_amount_split         := p_revenue_amount_split;
      l_srep_rec.non_revenue_amount_split     := p_non_revenue_amount_split;
      l_srep_rec.non_revenue_percent_split    := p_non_revenue_percent_split;
      l_srep_rec.revenue_percent_split        := p_revenue_percent_split;
      l_srep_rec.prev_cust_trx_line_salesrep_id
                                     := p_prev_cust_trx_line_srep_id;
      l_srep_rec.attribute_category           := p_attribute_category;
      l_srep_rec.attribute1                   := p_attribute1;
      l_srep_rec.attribute2                   := p_attribute2;
      l_srep_rec.attribute3                   := p_attribute3;
      l_srep_rec.attribute4                   := p_attribute4;
      l_srep_rec.attribute5                   := p_attribute5;
      l_srep_rec.attribute6                   := p_attribute6;
      l_srep_rec.attribute7                   := p_attribute7;
      l_srep_rec.attribute8                   := p_attribute8;
      l_srep_rec.attribute9                   := p_attribute9;
      l_srep_rec.attribute10                  := p_attribute10;
      l_srep_rec.attribute11                  := p_attribute11;
      l_srep_rec.attribute12                  := p_attribute12;
      l_srep_rec.attribute13                  := p_attribute13;
      l_srep_rec.attribute14                  := p_attribute14;
      l_srep_rec.attribute15                  := p_attribute15;
      l_srep_rec.revenue_salesgroup_id        := p_revenue_salesgroup_id;
      l_srep_rec.non_revenue_salesgroup_id    := p_non_revenue_salesgroup_id;

     /*-----------------------------------------------+
      |  Call the standard salescredit entity handler |
      +-----------------------------------------------*/

      insert_salescredit(
                          p_form_name,
                          p_form_version,
                          p_run_auto_accounting_flag,
                          l_srep_rec,
                          p_cust_trx_line_salesrep_id,
                          p_status );
      /* bug 3607146 */
      arp_rounding.correct_scredit_rounding_errs( p_customer_trx_id,
                                                     l_scredit_count);

      arp_util.debug('arp_process_salescredit.insert_salescredit_cover()-');

EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug(
           'EXCEPTION:  arp_process_salescredit.insert_salescredit_cover()');

    arp_util.debug('------- parameters for insert_salescredit_cover() ' ||
                   '---------');
    arp_util.debug('p_form_name                   = ' || p_form_name );
    arp_util.debug('p_form_version                = ' || p_form_version );
    arp_util.debug('p_run_auto_accounting_flag    = ' ||
                arp_trx_util.boolean_to_varchar2(p_run_auto_accounting_flag) );
    arp_util.debug('p_customer_trx_id             = ' || p_customer_trx_id );
    arp_util.debug('p_customer_trx_line_id        = ' ||
                   p_customer_trx_line_id );
    arp_util.debug('p_salesrep_id                 = ' ||
                   p_salesrep_id );
    arp_util.debug('p_revenue_amount_split        = ' ||
                   p_revenue_amount_split );
    arp_util.debug('p_non_revenue_amount_split    = ' ||
                   p_non_revenue_amount_split );
    arp_util.debug('p_non_revenue_percent_split   = ' ||
                    p_non_revenue_percent_split );
    arp_util.debug('p_revenue_percent_split       = ' ||
                    p_revenue_percent_split );
    arp_util.debug('p_prev_cust_trx_line_srep_id  = ' ||
                   p_prev_cust_trx_line_srep_id );
    arp_util.debug('p_attribute_category          = ' ||
                   p_attribute_category );
    arp_util.debug('p_attribute1                  = ' || p_attribute1 );
    arp_util.debug('p_attribute2                  = ' || p_attribute2 );
    arp_util.debug('p_attribute3                  = ' || p_attribute3 );
    arp_util.debug('p_attribute4                  = ' || p_attribute4 );
    arp_util.debug('p_attribute5                  = ' || p_attribute5 );
    arp_util.debug('p_attribute6                  = ' || p_attribute6 );
    arp_util.debug('p_attribute7                  = ' || p_attribute7 );
    arp_util.debug('p_attribute8                  = ' || p_attribute8 );
    arp_util.debug('p_attribute9                  = ' || p_attribute9 );
    arp_util.debug('p_attribute10                 = ' || p_attribute10 );
    arp_util.debug('p_attribute11                 = ' || p_attribute11 );
    arp_util.debug('p_attribute12                 = ' || p_attribute12 );
    arp_util.debug('p_attribute13                 = ' || p_attribute13 );
    arp_util.debug('p_attribute14                 = ' || p_attribute14 );
    arp_util.debug('p_attribute15                 = ' || p_attribute15 );
    arp_util.debug('p_revenue_salesgroup_id       = ' || p_revenue_salesgroup_id );
    arp_util.debug('p_non_revenue_salesgroup_id   = ' || p_non_revenue_salesgroup_id );

    RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_salescredit_cover						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a salescredit record and                 |
 |    updates a salescredit line.                                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_run_auto_accounting_flag			     |
 |                    p_backout_flag                                         |
 |		      p_cust_trx_line_salesrep_id 			     |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_salesrep_id                                          |
 |                    p_revenue_amount_split                                 |
 |                    p_non_revenue_amount_split                             |
 |                    p_non_revenue_percent_split                            |
 |                    p_revenue_percent_split                                |
 |                    p_prev_cust_trx_line_srep_id                           |
 |                    p_attribute_category                                   |
 |                    p_attribute1                                           |
 |                    p_attribute2                                           |
 |                    p_attribute3                                           |
 |                    p_attribute4                                           |
 |                    p_attribute5                                           |
 |                    p_attribute6                                           |
 |                    p_attribute7                                           |
 |                    p_attribute8                                           |
 |                    p_attribute9                                           |
 |                    p_attribute10                                          |
 |                    p_attribute11                                          |
 |                    p_attribute12                                          |
 |                    p_attribute13                                          |
 |                    p_attribute14                                          |
 |                    p_attribute15                                          |
 |                    p_revenue_salesgroup_id                                |
 |                    p_non_revenue_salesgroup_id                            |
 |              OUT:                                                         |
 |                    p_backout_done_flag 				     |
 |                    p_status		 				     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_salescredit_cover(
           p_form_name                       IN varchar2,
           p_form_version                    IN number,
           p_run_auto_accounting_flag        IN boolean,
           p_backout_flag                    IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_backout_done_flag              OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2,
           p_revenue_salesgroup_id           IN
                    ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                    ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null)
                   IS

      l_srep_rec ra_cust_trx_line_salesreps%rowtype;

      /* bug 3607146 */
      l_scredit_count NUMBER;

BEGIN

      arp_util.debug('arp_process_salescredit.update_salescredit_cover()+');

     /*------------------------------------------------+
      |  Populate the salescredit record group with    |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      arp_ctls_pkg.set_to_dummy(l_srep_rec);

      l_srep_rec.customer_trx_id              := p_customer_trx_id;
      l_srep_rec.customer_trx_line_id         := p_customer_trx_line_id;
      l_srep_rec.salesrep_id                  := p_salesrep_id;
      l_srep_rec.revenue_amount_split         := p_revenue_amount_split;
      l_srep_rec.non_revenue_amount_split     := p_non_revenue_amount_split;
      l_srep_rec.non_revenue_percent_split    := p_non_revenue_percent_split;
      l_srep_rec.revenue_percent_split        := p_revenue_percent_split;
      l_srep_rec.prev_cust_trx_line_salesrep_id
                                     := p_prev_cust_trx_line_srep_id;
      l_srep_rec.attribute_category           := p_attribute_category;
      l_srep_rec.attribute1                   := p_attribute1;
      l_srep_rec.attribute2                   := p_attribute2;
      l_srep_rec.attribute3                   := p_attribute3;
      l_srep_rec.attribute4                   := p_attribute4;
      l_srep_rec.attribute5                   := p_attribute5;
      l_srep_rec.attribute6                   := p_attribute6;
      l_srep_rec.attribute7                   := p_attribute7;
      l_srep_rec.attribute8                   := p_attribute8;
      l_srep_rec.attribute9                   := p_attribute9;
      l_srep_rec.attribute10                  := p_attribute10;
      l_srep_rec.attribute11                  := p_attribute11;
      l_srep_rec.attribute12                  := p_attribute12;
      l_srep_rec.attribute13                  := p_attribute13;
      l_srep_rec.attribute14                  := p_attribute14;
      l_srep_rec.attribute15                  := p_attribute15;
      l_srep_rec.revenue_salesgroup_id        := p_revenue_salesgroup_id;
      l_srep_rec.non_revenue_salesgroup_id    := p_non_revenue_salesgroup_id;


     /*-----------------------------------------------+
      |  Call the standard salescredit entity handler |
      +-----------------------------------------------*/

      update_salescredit(
                          p_form_name,
                          p_form_version,
                          p_run_auto_accounting_flag,
                          p_backout_flag,
                          p_cust_trx_line_salesrep_id,
                          p_customer_trx_id,
                          p_customer_trx_line_id,
                          l_srep_rec,
                          p_backout_done_flag,
                          p_status );

      /* bug 3607146 */
      arp_rounding.correct_scredit_rounding_errs( p_customer_trx_id,
                                                     l_scredit_count);

      arp_util.debug('arp_process_salescredit.update_salescredit_cover()-');

EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug(
           'EXCEPTION:  arp_process_salescredit.update_salescredit_cover()');

    arp_util.debug('------- parameters for update_salescredit_cover() ' ||
                   '---------');
    arp_util.debug('p_form_name                   = ' || p_form_name );
    arp_util.debug('p_form_version                = ' || p_form_version );
    arp_util.debug('p_run_auto_accounting_flag    = ' ||
                arp_trx_util.boolean_to_varchar2(p_run_auto_accounting_flag) );
    arp_util.debug('p_backout_flag                = ' ||
                          arp_trx_util.boolean_to_varchar2(p_backout_flag) );
    arp_util.debug('p_customer_trx_id             = ' || p_customer_trx_id );
    arp_util.debug('p_customer_trx_line_id        = ' ||
                   p_customer_trx_line_id );
    arp_util.debug('p_salesrep_id                 = ' ||
                   p_salesrep_id );
    arp_util.debug('p_revenue_amount_split        = ' ||
                   p_revenue_amount_split );
    arp_util.debug('p_non_revenue_amount_split    = ' ||
                   p_non_revenue_amount_split );
    arp_util.debug('p_non_revenue_percent_split   = ' ||
                    p_non_revenue_percent_split );
    arp_util.debug('p_revenue_percent_split       = ' ||
                    p_revenue_percent_split );
    arp_util.debug('p_prev_cust_trx_line_srep_id  = ' ||
                   p_prev_cust_trx_line_srep_id );
    arp_util.debug('p_attribute_category          = ' ||
                   p_attribute_category );
    arp_util.debug('p_attribute1                  = ' || p_attribute1 );
    arp_util.debug('p_attribute2                  = ' || p_attribute2 );
    arp_util.debug('p_attribute3                  = ' || p_attribute3 );
    arp_util.debug('p_attribute4                  = ' || p_attribute4 );
    arp_util.debug('p_attribute5                  = ' || p_attribute5 );
    arp_util.debug('p_attribute6                  = ' || p_attribute6 );
    arp_util.debug('p_attribute7                  = ' || p_attribute7 );
    arp_util.debug('p_attribute8                  = ' || p_attribute8 );
    arp_util.debug('p_attribute9                  = ' || p_attribute9 );
    arp_util.debug('p_attribute10                 = ' || p_attribute10 );
    arp_util.debug('p_attribute11                 = ' || p_attribute11 );
    arp_util.debug('p_attribute12                 = ' || p_attribute12 );
    arp_util.debug('p_attribute13                 = ' || p_attribute13 );
    arp_util.debug('p_attribute14                 = ' || p_attribute14 );
    arp_util.debug('p_attribute15                 = ' || p_attribute15 );
    arp_util.debug('p_revenue_salesgroup_id       = ' || p_revenue_salesgroup_id );
    arp_util.debug('p_non_revenue_salesgroup_id   = ' || p_non_revenue_salesgroup_id );

    RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_salescredit_cover						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a salescredit record and                 |
 |    delete a salescredit line.                                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_run_auto_accounting_flag			     |
 |                    p_backout_flag                                         |
 |		      p_cust_trx_line_salesrep_id 			     |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_salesrep_id                                          |
 |                    p_revenue_amount_split                                 |
 |                    p_non_revenue_amount_split                             |
 |                    p_non_revenue_percent_split                            |
 |                    p_revenue_percent_split                                |
 |                    p_prev_cust_trx_line_srep_id                           |
 |                    p_attribute_category                                   |
 |                    p_attribute1                                           |
 |                    p_attribute2                                           |
 |                    p_attribute3                                           |
 |                    p_attribute4                                           |
 |                    p_attribute5                                           |
 |                    p_attribute6                                           |
 |                    p_attribute7                                           |
 |                    p_attribute8                                           |
 |                    p_attribute9                                           |
 |                    p_attribute10                                          |
 |                    p_attribute11                                          |
 |                    p_attribute12                                          |
 |                    p_attribute13                                          |
 |                    p_attribute14                                          |
 |                    p_attribute15                                          |
 |                    p_revenue_salesgroup_id                                |
 |                    p_non_revenue_salesgroup_id                            |
 |              OUT:                                                         |
 |                    p_backout_done_flag 				     |
 |                    p_status		 				     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE delete_salescredit_cover(
           p_form_name                       IN varchar2,
           p_form_version                    IN number,
           p_run_auto_accounting_flag        IN boolean,
           p_backout_flag                    IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_backout_done_flag              OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2,
           p_revenue_salesgroup_id           IN
                    ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                    ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null)
                   IS

      l_srep_rec ra_cust_trx_line_salesreps%rowtype;

      /* bug 3607146 */
      l_scredit_count NUMBER;

BEGIN

      arp_util.debug('arp_process_salescredit.delete_salescredit_cover()+');

     /*------------------------------------------------+
      |  Populate the salescredit record group with    |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      arp_ctls_pkg.set_to_dummy(l_srep_rec);

      l_srep_rec.customer_trx_id              := p_customer_trx_id;
      l_srep_rec.customer_trx_line_id         := p_customer_trx_line_id;
      l_srep_rec.salesrep_id                  := p_salesrep_id;
      l_srep_rec.revenue_amount_split         := p_revenue_amount_split;
      l_srep_rec.non_revenue_amount_split     := p_non_revenue_amount_split;
      l_srep_rec.non_revenue_percent_split    := p_non_revenue_percent_split;
      l_srep_rec.revenue_percent_split        := p_revenue_percent_split;
      l_srep_rec.prev_cust_trx_line_salesrep_id
                                     := p_prev_cust_trx_line_srep_id;
      l_srep_rec.attribute_category           := p_attribute_category;
      l_srep_rec.attribute1                   := p_attribute1;
      l_srep_rec.attribute2                   := p_attribute2;
      l_srep_rec.attribute3                   := p_attribute3;
      l_srep_rec.attribute4                   := p_attribute4;
      l_srep_rec.attribute5                   := p_attribute5;
      l_srep_rec.attribute6                   := p_attribute6;
      l_srep_rec.attribute7                   := p_attribute7;
      l_srep_rec.attribute8                   := p_attribute8;
      l_srep_rec.attribute9                   := p_attribute9;
      l_srep_rec.attribute10                  := p_attribute10;
      l_srep_rec.attribute11                  := p_attribute11;
      l_srep_rec.attribute12                  := p_attribute12;
      l_srep_rec.attribute13                  := p_attribute13;
      l_srep_rec.attribute14                  := p_attribute14;
      l_srep_rec.attribute15                  := p_attribute15;
      l_srep_rec.revenue_salesgroup_id        := p_revenue_salesgroup_id;
      l_srep_rec.non_revenue_salesgroup_id    := p_non_revenue_salesgroup_id;

     /*-----------------------------------------------+
      |  Call the standard salescredit entity handler |
      +-----------------------------------------------*/

      delete_salescredit(
                          p_form_name,
                          p_form_version,
                          p_run_auto_accounting_flag,
                          p_cust_trx_line_salesrep_id,
                          p_customer_trx_id,
                          p_customer_trx_line_id,
                          l_srep_rec,
                          p_backout_flag,
                          p_backout_done_flag,
                          p_status);

      /* bug 3607146 */
      arp_rounding.correct_scredit_rounding_errs( p_customer_trx_id,
                                                     l_scredit_count);

      arp_util.debug('arp_process_salescredit.delete_salescredit_cover()-');

EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug(
           'EXCEPTION:  arp_process_salescredit.delete_salescredit_cover()');

    arp_util.debug('------- parameters for delete_salescredit_cover() ' ||
                   '---------');
    arp_util.debug('p_form_name                   = ' || p_form_name );
    arp_util.debug('p_form_version                = ' || p_form_version );
    arp_util.debug('p_run_auto_accounting_flag    = ' ||
                arp_trx_util.boolean_to_varchar2(p_run_auto_accounting_flag) );
    arp_util.debug('p_backout_flag                = ' ||
                arp_trx_util.boolean_to_varchar2(p_backout_flag));
    arp_util.debug('p_customer_trx_id             = ' || p_customer_trx_id );
    arp_util.debug('p_customer_trx_line_id        = ' ||
                   p_customer_trx_line_id );
    arp_util.debug('p_salesrep_id                 = ' ||
                   p_salesrep_id );
    arp_util.debug('p_revenue_amount_split        = ' ||
                   p_revenue_amount_split );
    arp_util.debug('p_non_revenue_amount_split    = ' ||
                   p_non_revenue_amount_split );
    arp_util.debug('p_non_revenue_percent_split   = ' ||
                    p_non_revenue_percent_split );
    arp_util.debug('p_revenue_percent_split       = ' ||
                    p_revenue_percent_split );
    arp_util.debug('p_prev_cust_trx_line_srep_id  = ' ||
                   p_prev_cust_trx_line_srep_id );
    arp_util.debug('p_attribute_category          = ' ||
                   p_attribute_category );
    arp_util.debug('p_attribute1                  = ' || p_attribute1 );
    arp_util.debug('p_attribute2                  = ' || p_attribute2 );
    arp_util.debug('p_attribute3                  = ' || p_attribute3 );
    arp_util.debug('p_attribute4                  = ' || p_attribute4 );
    arp_util.debug('p_attribute5                  = ' || p_attribute5 );
    arp_util.debug('p_attribute6                  = ' || p_attribute6 );
    arp_util.debug('p_attribute7                  = ' || p_attribute7 );
    arp_util.debug('p_attribute8                  = ' || p_attribute8 );
    arp_util.debug('p_attribute9                  = ' || p_attribute9 );
    arp_util.debug('p_attribute10                 = ' || p_attribute10 );
    arp_util.debug('p_attribute11                 = ' || p_attribute11 );
    arp_util.debug('p_attribute12                 = ' || p_attribute12 );
    arp_util.debug('p_attribute13                 = ' || p_attribute13 );
    arp_util.debug('p_attribute14                 = ' || p_attribute14 );
    arp_util.debug('p_attribute15                 = ' || p_attribute15 );
    arp_util.debug('p_revenue_salesgroup_id       = ' || p_revenue_salesgroup_id );
    arp_util.debug('p_non_revenue_salesgroup_id   = ' || p_non_revenue_salesgroup_id );

    RAISE;

END;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

   pg_number_dummy := arp_ctls_pkg.get_number_dummy;

   /*  Bug 3607146 */
   pg_base_precision             := arp_global.base_precision;
   pg_base_min_acc_unit          := arp_global.base_min_acc_unit;
   pg_trx_header_level_rounding  := arp_global.sysparam.trx_header_level_rounding;

END ARP_PROCESS_SALESCREDIT;

/
