--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_DIST" AS
/* $Header: ARTELGDB.pls 120.8.12010000.5 2009/11/17 11:43:47 naneja ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

pg_number_dummy       number;

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
 | 		     p_cust_trx_line_gl_dist_id				     |
 |		     p_new_dist_rec 					     |
 |              OUT:                                                         |
 |		     p_posted_flag 					     |
 |		     p_ccid_changed_flag  				     |
 |		     p_amount_percent_changed_flag 			     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |     12-OCT-95  Martin Johnson      Replaced arp_trx_util.set_posted_flag  |
 |                                     with IF statment to determine if      |
 |                                     dist is posted (set_posted_flag       |
 |                                     determines if trx is posted)          |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_flags(p_cust_trx_line_gl_dist_id IN
                       ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
                    p_new_dist_rec       IN ra_cust_trx_line_gl_dist%rowtype,
                    p_posted_flag                  OUT NOCOPY boolean,
                    p_ccid_changed_flag            OUT NOCOPY boolean,
                    p_amount_percent_changed_flag  OUT NOCOPY boolean) IS

  l_old_dist_rec  		  ra_cust_trx_line_gl_dist%rowtype;
  l_posted_flag                   boolean;
  l_ccid_changed_flag         boolean;
  l_amount_percent_changed_flag   boolean;

BEGIN

   arp_util.debug('arp_process_dist.set_flags()+');

   arp_ctlgd_pkg.fetch_p( l_old_dist_rec,
                          p_cust_trx_line_gl_dist_id);


   IF     (
             l_old_dist_rec.code_combination_id <>
                                     p_new_dist_rec.code_combination_id AND
             p_new_dist_rec.code_combination_id <> pg_number_dummy
          )
   THEN   l_ccid_changed_flag := TRUE;
   ELSE   l_ccid_changed_flag := FALSE;
   END IF;

   IF     (
            (
               nvl(l_old_dist_rec.amount, 0) <> nvl(p_new_dist_rec.amount, 0)
             AND
               p_new_dist_rec.amount <> pg_number_dummy
            ) OR
            (
               nvl(l_old_dist_rec.percent, 0) <> nvl(p_new_dist_rec.percent, 0)
             AND
               p_new_dist_rec.percent <> pg_number_dummy
            )
          )
   THEN  l_amount_percent_changed_flag := TRUE;
   ELSE  l_amount_percent_changed_flag := FALSE;
   END IF;

   IF ( l_old_dist_rec.gl_posted_date IS NULL )
     THEN l_posted_flag := FALSE;
     ELSE l_posted_flag := TRUE;
   END IF;

   p_posted_flag	         := l_posted_flag;
   p_ccid_changed_flag	 	 := l_ccid_changed_flag;
   p_amount_percent_changed_flag := l_amount_percent_changed_flag;

   arp_util.debug('p_posted_flag                 = ' ||
                  arp_trx_util.boolean_to_varchar2(l_posted_flag));

   arp_util.debug('p_ccid_changed_flag           = ' ||
                 arp_trx_util.boolean_to_varchar2( l_ccid_changed_flag));

   arp_util.debug('p_amount_percent_changed_flag = ' ||
                  arp_trx_util.boolean_to_varchar2(
                                         l_amount_percent_changed_flag));

   arp_util.debug('arp_process_dist.set_flags()-');

EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_process_dist.set_flags()');

   arp_util.debug('');
   arp_util.debug('---------- parameters for set_flags() ---------');

   arp_util.debug('p_cust_trx_line_gl_dist_id = ' ||
                  p_cust_trx_line_gl_dist_id);

   arp_util.debug('');

   arp_util.debug('---------- new distribution record ----------');
   arp_ctlgd_pkg.display_dist_rec( p_new_dist_rec );
   arp_util.debug('');

   RAISE;

END;

/*===========================================================================+
 | PROCEDURE validate_and_default_gl_date                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns a default GL date                                              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_gl_date                                              |
 |                    p_trx_date                                             |
 |                    p_invoicing_rule_id                                    |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    p_default_gl_date                                      |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-NOV-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE validate_and_default_gl_date(
               p_gl_date           IN date,
               p_trx_date          IN date,
               p_invoicing_rule_id IN
                 ra_customer_trx.invoicing_rule_id%type,
               p_default_gl_date   IN OUT NOCOPY date)
IS

   l_result                boolean;
   l_gl_date               date;
   l_trx_date              date;
   l_defaulting_rule_used  varchar2(300);
   l_error_message         varchar2(300);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_dist.validate_and_default_gl_date()+');
   END IF;

   /* bug-7147479  Use GL Date as passed.Commented out the below lines of code
      which assigns null when invoicing rule id is not null*/
   l_gl_date  := p_gl_date;
   l_trx_date := p_trx_date;
   /*IF ( p_invoicing_rule_id IS NOT NULL)
     THEN

       l_gl_date  := null;
       l_trx_date := null;

     ELSE

       l_gl_date  := p_gl_date;
       l_trx_date := p_trx_date;

   END IF;*/

   l_result := arp_util.validate_and_default_gl_date(
                                     l_gl_date,
                                     l_trx_date,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     null,
                                     p_invoicing_rule_id,
                                     arp_global.set_of_books_id,
                                     222,
                                     p_default_gl_date,
                                     l_defaulting_rule_used,
                                     l_error_message );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(   'p_default_gl_date: ' ||
                                TO_CHAR(p_default_gl_date, 'DD-MON-YYYY') );
      arp_util.debug(   'l_defaulting_rule_used: ' ||
                                l_defaulting_rule_used );
      arp_util.debug(   'l_error_message: ' || l_error_message );
   END IF;

   IF ( not l_result )
     THEN
       fnd_message.set_name('AR', 'GENERIC_MESSAGE');
       fnd_message.set_token('GENERIC_TEXT', l_error_message);
       app_exception.raise_exception;

     ELSIF ( p_default_gl_date IS NULL )
       THEN
         fnd_message.set_name('AR', 'AR_DIST_BACKOUT_GL_DATE');
         app_exception.raise_exception;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_dist.validate_and_default_gl_date()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN

     /*---------------------------------------------+
      |  Display parameters and raise the exception |
      +---------------------------------------------*/

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug(
            'EXCEPTION:  arp_process_dist.validate_and_default_gl_date()');
         arp_util.debug(  '');
         arp_util.debug(
        '---------- parameters for validate_and_default_gl_date() ---------');
         arp_util.debug(  'p_gl_date           = ' || p_gl_date );
         arp_util.debug(  'p_trx_date          = ' || p_trx_date );
         arp_util.debug(  'p_invoicing_rule_id = ' || p_invoicing_rule_id );
      END IF;

      RAISE;

END validate_and_default_gl_date;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    backout_ccid							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts two records to backout the existing dist record.	             |
 |    This procedure is called if backout is required and the dist's         |
 |    code_combination_id has changed.	 		      	             |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_old_dist_rec					     |
 |		      p_new_dist_rec					     |
 |                    p_header_gl_date                                       |
 |                    p_trx_date                                             |
 |                    p_invoicing_rule_id                                    |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |     08-NOV-95  Martin Johnson      Made cust_trx_line_salesrep_id and     |
 |                                      gl_posted_date null for new dist.    |
 |                                      Call validate_and_default_gl_date()  |
 |                                      to get gl_date.                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE backout_ccid(
               p_old_dist_rec      IN ra_cust_trx_line_gl_dist%rowtype,
               p_new_dist_rec      IN ra_cust_trx_line_gl_dist%rowtype,
               p_header_gl_date    IN date,
               p_trx_date          IN date,
               p_invoicing_rule_id IN ra_customer_trx.invoicing_rule_id%type,
               p_exchange_rate     IN ra_customer_trx.exchange_rate%type,
               p_currency_code     IN fnd_currencies.currency_code%type,
               p_precision         IN fnd_currencies.precision%type,
               p_mau               IN
                                  fnd_currencies.minimum_accountable_unit%type
                      )  IS

   l_cust_trx_line_gl_dist_id
                   ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

   l_old_dist_rec   ra_cust_trx_line_gl_dist%rowtype;
   l_new_dist_rec   ra_cust_trx_line_gl_dist%rowtype;

   /* Bug 3598021 - 3630436 */
   l_orig_dist_rec  ra_cust_trx_line_gl_dist%rowtype;

   l_default_gl_date       date;

BEGIN

   arp_util.debug('arp_process_dist.backout_ccid()+');

   l_old_dist_rec := p_old_dist_rec;
   l_new_dist_rec := p_new_dist_rec;


   /*--------------------------+
    |    insert the new row    |
    +--------------------------*/


   /*---------------------------------------------------------------+
    |    If a new value was specified in the dist rec passed into   |
    |    update_dist() use that value. Otherwise, use the  	    |
    |    value from the original dist line.               	    |
    +---------------------------------------------------------------*/

   arp_ctlgd_pkg.merge_dist_recs( l_old_dist_rec,
                                  l_new_dist_rec,
                                  l_new_dist_rec);

   /* Bug 7039029 JVARKEY cust_trx_line_salesrep_id should be retained in
      the newly created distribution*/
   --l_new_dist_rec.cust_trx_line_salesrep_id := null;
   l_new_dist_rec.gl_posted_date := null;

   /*Bug-7147479 Pass GL DATE in l_default_gl_Date and
 	Pass NVL(l_old_dist_rec.gl_date,p_header_gl_date)
     The purpose is to use the GL Date on the old line if it is valid
   */
   l_default_gl_date:=NVL(l_old_dist_rec.gl_date,p_header_gl_date);
   validate_and_default_gl_date(NVL(l_old_dist_rec.gl_date,p_header_gl_date),
                                p_trx_date,
                                p_invoicing_rule_id,
                                l_default_gl_date );

   l_new_dist_rec.gl_date          := l_default_gl_date;
   l_new_dist_rec.original_gl_date := l_default_gl_date;
   l_new_dist_rec.ccid_change_flag := 'Y'; /* Bug 8788491 */

   /*Bug 9085085 when both CCID and amount are changed we need to correct acctd amount
     as well for new row being inserted */

   IF     (
            (
               nvl(l_old_dist_rec.amount, 0) <> nvl(l_new_dist_rec.amount, 0)
             AND
               p_new_dist_rec.amount <> pg_number_dummy
            ) OR
            (
               nvl(l_old_dist_rec.percent, 0) <> nvl(l_new_dist_rec.percent, 0)
             AND
               l_new_dist_rec.percent <> pg_number_dummy
            )
          )
   THEN
     arp_util.debug('Before setting Acctd amount');
     l_new_dist_rec.acctd_amount := arpcurr.functional_amount(
                          l_new_dist_rec.amount,
                          p_currency_code,
                          p_exchange_rate,
                          p_precision,
                          p_mau);
   END IF;

   /*-----------------------------------------------------------+
    |    Call the table handler to insert the new dist record   |
    +-----------------------------------------------------------*/

   arp_ctlgd_pkg.insert_p( l_new_dist_rec,
                           l_cust_trx_line_gl_dist_id,
                           p_exchange_rate,
                           p_currency_code,
                           p_precision,
                           p_mau);

    /* Bug 8788491
       Posted dist can be modified only once.
       Dont allow this dist to modify here onwards. */
    ARP_CTLGD_PKG.set_to_dummy(l_orig_dist_rec );
    l_orig_dist_rec.ccid_change_flag := 'N';
    ARP_CTLGD_PKG.update_p( l_orig_dist_rec ,
                                l_old_dist_rec.cust_trx_line_gl_dist_id );

   /* 6325023 - the point of the rec_offset_flag was to keep header level UNEARN
       rows (all of them) together to make troubleshooting data issues easier.
       I am removing the code here that sets the rec_offset_flags of the older/
       existing rows to null as that is contrary to the point of this column
   /+ Bug 3598021  - 3630436 +/
   IF l_old_dist_rec.rec_offset_flag = 'Y'
   THEN
      ARP_CTLGD_PKG.set_to_dummy(l_orig_dist_rec );
      l_orig_dist_rec.rec_offset_flag := NULL;
      ARP_CTLGD_PKG.update_p( l_orig_dist_rec ,
                                l_old_dist_rec.cust_trx_line_gl_dist_id );
   END IF;

   END of bug 6325023 */

   /*-------------------------------------+
    |    backout the original dist row    |
    +-------------------------------------*/

   l_old_dist_rec.amount       := -1 * l_old_dist_rec.amount;

   l_old_dist_rec.acctd_amount := -1 * l_old_dist_rec.acctd_amount;

   l_old_dist_rec.percent      := -1 * l_old_dist_rec.percent;

   /* 6325023 - Keep the Srep ID populated.. no reason not to
   l_old_dist_rec.cust_trx_line_salesrep_id := null; */

   l_old_dist_rec.gl_posted_date := null;

   l_old_dist_rec.gl_date          := l_default_gl_date;
   l_old_dist_rec.original_gl_date := l_default_gl_date;

   /* 6325023 - do not null rec_offset_flag
   /+ Bug 3598021 - 3630436  +/
   l_old_dist_rec.rec_offset_flag := NULL;
   END of bug 6325023 */

   l_old_dist_rec.ccid_change_flag := 'N';  /* Bug 8788491 */

   arp_ctlgd_pkg.insert_p( l_old_dist_rec,
                           l_cust_trx_line_gl_dist_id,
                           p_exchange_rate,
                           p_currency_code,
                           p_precision,
                           p_mau);

   arp_util.debug('arp_process_dist.backout_ccid()-');

EXCEPTION
  WHEN OTHERS THEN

     /*---------------------------------------------+
      |  Display parameters and raise the exception |
      +---------------------------------------------*/

      arp_util.debug('EXCEPTION:  arp_process_dist.backout_ccid()');
      arp_util.debug('');
      arp_util.debug('---------- parameters for backout_ccid() ---------');

      arp_util.debug('p_header_gl_date    = ' || p_header_gl_date);
      arp_util.debug('p_trx_date          = ' || p_trx_date);
      arp_util.debug('p_invoicing_rule_id = ' || p_invoicing_rule_id);
      arp_util.debug('p_exchange_rate     = ' || p_exchange_rate);
      arp_util.debug('p_currency_code     = ' || p_currency_code);
      arp_util.debug('p_precision         = ' || p_precision );
      arp_util.debug('p_mau               = ' || p_mau );

      arp_util.debug('');

      RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    backout_amount							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts one record to backout the existing dist record.		     |
 |    This procedure is called if backout is required and the amount or      |
 |    percent of a dist record has changed.				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 | 		      p_old_dist_rec					     |
 | 		      p_new_dist_rec					     |
 |                    p_header_gl_date                                       |
 |                    p_trx_date                                             |
 |                    p_invoicing_rule_id                                    |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |     08-NOV-95  Martin Johnson      Made cust_trx_line_salesrep_id and     |
 |                                      gl_posted_date null for new dist.    |
 |                                      Call validate_and_default_gl_date()  |
 |                                      to get gl_date.                      |
 |                                                                           |
 +===========================================================================*/


PROCEDURE backout_amount(
               p_old_dist_rec      IN ra_cust_trx_line_gl_dist%rowtype,
               p_new_dist_rec      IN ra_cust_trx_line_gl_dist%rowtype,
               p_header_gl_date    IN date,
               p_trx_date          IN date,
               p_invoicing_rule_id IN ra_customer_trx.invoicing_rule_id%type,
               p_exchange_rate     IN ra_customer_trx.exchange_rate%type,
               p_currency_code     IN fnd_currencies.currency_code%type,
               p_precision         IN fnd_currencies.precision%type,
               p_mau               IN
                                  fnd_currencies.minimum_accountable_unit%type
                        )  IS


   l_cust_trx_line_gl_dist_id
                   ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

   l_old_dist_rec ra_cust_trx_line_gl_dist%rowtype;
   l_new_dist_rec ra_cust_trx_line_gl_dist%rowtype;

   l_default_gl_date       date;

BEGIN

   arp_util.debug('arp_process_dist.backout_amount()+');

   l_old_dist_rec := p_old_dist_rec;
   l_new_dist_rec := p_new_dist_rec;

   /*---------------------------------------------------------------+
    |    create an offsetting record  to preserve the audit trail   |
    +---------------------------------------------------------------*/


   l_new_dist_rec.amount  := l_new_dist_rec.amount - l_old_dist_rec.amount;

   l_new_dist_rec.percent := l_new_dist_rec.percent - l_old_dist_rec.percent;

   /*---------------------------------------------------------------+
    |    If a new value was specified in the dist rec passed into   |
    |    update_dist(), use that value. Otherwise, use the	    |
    |    value from the original dist record.                	    |
    +---------------------------------------------------------------*/

   arp_ctlgd_pkg.merge_dist_recs( l_old_dist_rec,
                                  l_new_dist_rec,
                                  l_old_dist_rec);

  /*--------------------------------------------------------+
   |  Force insert_p() to recalculate the accounted amount  |
   |  instead of using the value from the old dist record.  |
   +--------------------------------------------------------*/

   l_old_dist_rec.acctd_amount := null;

   /* 6325023 - no reason to null srep ID
   l_old_dist_rec.cust_trx_line_salesrep_id := null; */

   l_old_dist_rec.gl_posted_date := null;
   /*Bug-7147479 Pass GL DATE in l_default_gl_Date and
 	Pass NVL(l_old_dist_rec.gl_date,p_header_gl_date)
     The purpose is to use the GL Date on the old line if it is valid
   */
   l_default_gl_date:=NVL(l_old_dist_rec.gl_date,p_header_gl_date);
   validate_and_default_gl_date(NVL(l_old_dist_rec.gl_date,p_header_gl_date),
                                p_trx_date,
                                p_invoicing_rule_id,
                                l_default_gl_date );

   l_old_dist_rec.gl_date          := l_default_gl_date;
   l_old_dist_rec.original_gl_date := l_default_gl_date;

  /*------------------------------------------------------------+
   |  Call the table handler to create the backout dist record  |
   +------------------------------------------------------------*/

   arp_ctlgd_pkg.insert_p( l_old_dist_rec,
                           l_cust_trx_line_gl_dist_id,
                           p_exchange_rate,
                           p_currency_code,
                           p_precision,
                           p_mau);


   arp_util.debug('arp_process_dist.backout_amount()-');

EXCEPTION
    WHEN OTHERS THEN

     /*---------------------------------------------+
      |  Display parameters and raise the exception |
      +---------------------------------------------*/

      arp_util.debug('EXCEPTION:  arp_process_dist.backout_amount()');
      arp_util.debug('');
      arp_util.debug('---------- parameters for backout_amount() ---------');

      arp_util.debug('p_header_gl_date    = ' || p_header_gl_date);
      arp_util.debug('p_trx_date          = ' || p_trx_date);
      arp_util.debug('p_invoicing_rule_id = ' || p_invoicing_rule_id);
      arp_util.debug('p_exchange_rate     = ' || p_exchange_rate);
      arp_util.debug('p_currency_code     = ' || p_currency_code);
      arp_util.debug('p_precision         = ' || p_precision );
      arp_util.debug('p_mau               = ' || p_mau );

      arp_util.debug('');

      RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_tax_from_revenue		               		             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate Revenue Account tax code is used at the Transaction line      |
 |    if the system option enforces tax code from GL for a completed         |
 |    transaction. Validation will be performed during completion for        |
 |    incomplete transactions.                                               |
 |    This is enforced for On-Account Credit Memos, Debit Memos and Invoices.|
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_dist_rec					     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     02-Oct-97  Mahesh Sabapathy    Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE val_tax_from_revenue (
		p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype ) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_dist.val_tax_from_revenue()+');
   END IF;

   /* 4594101 - Removing validate_tax_enforcement
         this is handled by etax during calculation */

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_dist.val_tax_from_revenue()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(
               'EXCEPTION:  arp_process_dist.val_tax_from_revenue()');
           arp_util.debug('---------- val_tax_from_revenue() ---------');
        END IF;
        arp_ctlgd_pkg.display_dist_rec(p_dist_rec);

        RAISE;

END val_tax_from_revenue;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_insert_dist		               		                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation necessary when a new dist is inserted.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_dist_rec					     |
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


PROCEDURE val_insert_dist ( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_dist.val_insert_dist()+');


   arp_util.debug('arp_process_dist.val_val_insert_dist()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug(
               'EXCEPTION:  arp_process_dist.val_insert_dist()');

        arp_util.debug('---------- val_insert_dist() ---------');
        arp_ctlgd_pkg.display_dist_rec(p_dist_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_update_dist		          	                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a dist is updated.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |	  	      p_dist_rec					     |
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

PROCEDURE val_update_dist ( p_dist_rec IN  ra_cust_trx_line_gl_dist%rowtype )
                       IS


BEGIN

   arp_util.debug('arp_process_dist.val_update_dist()+');


   arp_util.debug('arp_process_dist.val_val_update_dist()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug(
               'EXCEPTION:  arp_process_dist.val_update_dist()');


        arp_util.debug('---------- val_update_dist() ---------');
        arp_ctlgd_pkg.display_dist_rec(p_dist_rec);

        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_delete_dist			                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Does validation that is required when a dist is deleted.		     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |	  	      p_dist_rec					     |
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

PROCEDURE val_delete_dist ( p_dist_rec IN ra_cust_trx_line_gl_dist%rowtype ) IS


BEGIN

   arp_util.debug('arp_process_dist.val_delete_dist()+');


   arp_util.debug('arp_process_dist.val_delete_dist()-');

EXCEPTION
    WHEN OTHERS THEN

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/

        arp_util.debug('EXCEPTION:  arp_process_dist.val_delete_dist()');


        arp_util.debug('---------- val_update_dist() ---------');
        arp_ctlgd_pkg.display_dist_rec(p_dist_rec);

       RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_dist							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ra_cust_trx_line_gl_dist			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_dist_rec					     |
 |		      p_cust_trx_line_gl_dist_id 			     |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |              OUT:                                                         |
 |                    p_cust_trx_line_gl_dist_id                             |
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


PROCEDURE insert_dist(
           p_form_name     IN varchar2,
           p_form_version  IN number,
           p_dist_rec	   IN ra_cust_trx_line_gl_dist%rowtype,
           p_exchange_rate IN ra_customer_trx.exchange_rate%type DEFAULT 1,
           p_currency_code IN fnd_currencies.currency_code%type  DEFAULT null,
           p_precision     IN fnd_currencies.precision%type      DEFAULT null,
           p_mau           IN fnd_currencies.minimum_accountable_unit%type
                              DEFAULT null,
           p_cust_trx_line_gl_dist_id  OUT NOCOPY
              ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type)
                   IS


   l_cust_trx_line_gl_dist_id
                   ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

--bug#2750340
   l_ev_rec        arp_xla_events.xla_events_type;
BEGIN

      arp_util.debug('arp_process_dist.insert_dist()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_dist.val_insert_dist(p_dist_rec);

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_dist_rec.customer_trx_id);


      arp_ctlgd_pkg.insert_p( p_dist_rec,
                              p_cust_trx_line_gl_dist_id,
                              p_exchange_rate,
                              p_currency_code,
                              p_precision,
                              p_mau);


       /*----------------------------------------------------+
        |  Validate tax from revenue account.                |
        +----------------------------------------------------*/
      val_tax_from_revenue( p_dist_rec );

--bug#2750340
      --------------------------------------------------------------
      --  Need to call AR XLA events because when user insert the
      --  a distribution directly through Trx WB, the distributions
      --  are created by this api.
      --  Call XLA event with the doc id
      --------------------------------------------------------------
      l_ev_rec.xla_from_doc_id   := p_dist_rec.customer_trx_id;
      l_ev_rec.xla_to_doc_id     := p_dist_rec.customer_trx_id;
      l_ev_rec.xla_req_id        := NULL;
      l_ev_rec.xla_doc_table     := 'CT';
      l_ev_rec.xla_doc_event     := NULL;
      l_ev_rec.xla_mode          := 'O';
      l_ev_rec.xla_call          := 'B';
      l_ev_rec.xla_fetch_size    := 999;
      arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );

      arp_util.debug('arp_process_dist.insert_dist()-');

EXCEPTION
  WHEN OTHERS THEN

    arp_util.debug('EXCEPTION:  arp_process_dist.insert_dist()');

   /*---------------------------------------------+
    |  Display parameters and raise the exception |
    +---------------------------------------------*/

    arp_util.debug('EXCEPTION:  arp_process_dist.set_flags()');

    arp_util.debug('');
    arp_util.debug('---------- insert_dist() ---------');

    arp_util.debug('p_form_name         = ' || p_form_name);
    arp_util.debug('p_form_version      = ' || p_form_version);
    arp_util.debug('p_exchange_rate     = ' || p_exchange_rate);
    arp_util.debug('p_currency_code     = ' || p_currency_code);
    arp_util.debug('p_precision         = ' || p_precision );
    arp_util.debug('p_mau               = ' || p_mau );

    arp_util.debug('');
    arp_ctlgd_pkg.display_dist_rec( p_dist_rec );
    arp_util.debug('');

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_dist						    	     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a record in ra_cust_trx_line_gl_dist			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_cust_trx_line_gl_dist_id  			     |
 |		      p_customer_trx_id		  			     |
 |		      p_dist_rec					     |
 |                    p_header_gl_date                                       |
 |                    p_trx_date                                             |
 |                    p_invoicing_rule_id                                    |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |              OUT:                                                         |
 |		      p_backout_done_flag                                    |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |     07-NOV-95  Martin Johnson      Added OUT parameter p_backout_done_flag|
 |                                    Added IN parameters p_header_gl_date,  |
 |                                      p_trx_date, p_invoicing_rule_id      |
 |     28-MAY-03  Herve   Yu          Added XLA plug ins bug#2979254         |
 |                                                                           |
 +===========================================================================*/


PROCEDURE update_dist(
           p_form_name                 IN varchar2,
           p_form_version              IN number,
           p_backout_flag              IN boolean,
           p_cust_trx_line_gl_dist_id  IN
                    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id	       IN ra_customer_trx.customer_trx_id%type,
           p_dist_rec		       IN OUT NOCOPY ra_cust_trx_line_gl_dist%rowtype,
           p_header_gl_date            IN date,
           p_trx_date                  IN date,
           p_invoicing_rule_id         IN
                    ra_customer_trx.invoicing_rule_id%type,
           p_backout_done_flag         OUT NOCOPY boolean,
           p_exchange_rate             IN ra_customer_trx.exchange_rate%type
                                          DEFAULT 1,
           p_currency_code             IN fnd_currencies.currency_code%type
                                          DEFAULT null,
           p_precision                 IN fnd_currencies.precision%type
                                          DEFAULT null,
           p_mau                       IN
                                   fnd_currencies.minimum_accountable_unit%type
                                   DEFAULT null )
                   IS


   l_cust_trx_line_gl_dist_id
                   ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type;

   l_old_dist_rec	   ra_cust_trx_line_gl_dist%rowtype;

   l_backout_flag	   boolean;
   l_posted_flag	   boolean;
   l_ccid_changed_flag     boolean;
   l_amount_percent_changed_flag   boolean;

   /* Variables l_open_rec, l_ctt_type, l_previous_customer_trx_id
      l_ae_doc_rec added for bug 1580221 */

   l_open_rec VARCHAR2(1);
   l_ctt_type VARCHAR2(20);
   l_previous_customer_trx_id NUMBER;
   l_ae_doc_rec arp_acct_main.ae_doc_rec_type;

--BUG#2750340
   l_ev_rec           arp_xla_events.xla_events_type;

BEGIN

      arp_util.debug('arp_process_dist.update_dist()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      set_flags(p_cust_trx_line_gl_dist_id,
                p_dist_rec,
                l_posted_flag,
                l_ccid_changed_flag,
                l_amount_percent_changed_flag);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_dist.val_update_dist(p_dist_rec);

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_customer_trx_id);

      /*------------------------------------------------------------------+
       |  Set the backout flag to true if the transaction has been posted |
       |  and the amounts or the account has changed.	                  |
       +------------------------------------------------------------------*/

      IF  ( l_posted_flag = TRUE  AND
            (
              l_ccid_changed_flag           = TRUE   OR
              l_amount_percent_changed_flag = TRUE
            )
          )
      THEN l_backout_flag := TRUE;
           arp_util.debug('revised backout flag: TRUE');
      ELSE l_backout_flag := p_backout_flag;

           arp_util.debug('revised backout flag: ' ||
                          arp_trx_util.boolean_to_varchar2(l_backout_flag ));

      END IF;

	/*------------------------------------------------------+
         |  If    backout is not required 			|
         |  THEN  do a simple update				|
         |  ELSE IF   the ccid has changed			|
         |       THEN create two offsetting records		|
         |       ELSE IF   the amount has changed		|
         |            THEN create one offsetting record		|
         |            ELSE do a simple update			|
	 +------------------------------------------------------*/

      IF   (l_backout_flag = FALSE)
      THEN
 	      /*--------------------------------------+
               |  Do a simple update with no backout. |
               +--------------------------------------*/

 	      /*-----------------------------------------------+
               |  Break the link to ra_cust_trx_line_salesreps |
               |  if the amount or account has been changed    |
               +-----------------------------------------------*/

  /* Bug 4053374 Link should be kept intact */
  /*             IF      (
                          p_dist_rec.cust_trx_line_salesrep_id IS NOT NULL AND
                          (
                             l_amount_percent_changed_flag = TRUE  OR
                             l_ccid_changed_flag           = TRUE  OR
                             p_dist_rec.code_combination_id = -1
                          )
                       )
               THEN    p_dist_rec.cust_trx_line_salesrep_id := null;
               END IF; */

 	      /*------------------------------------------------+
               |  Call the table handler to do a simple update  |
               +------------------------------------------------*/

               arp_util.debug('simple update - case 1');
               arp_ctlgd_pkg.update_p( p_dist_rec,
                                       p_cust_trx_line_gl_dist_id,
                                       p_exchange_rate,
                                       p_currency_code,
                                       p_precision,
                                       p_mau);

	       /* Following IF clause added for bug 1580221. */

               IF  (l_ccid_changed_flag = TRUE AND
                   l_amount_percent_changed_flag = FALSE AND
                   p_dist_rec.account_class = 'REC' ) THEN
                   BEGIN
                   SELECT ctt.accounting_affect_flag,
                          ctt.type,
                          ct.previous_customer_trx_id
                     INTO
                          l_open_rec,
                          l_ctt_type,
                          l_previous_customer_trx_id
                     FROM ra_cust_trx_types ctt,
                          ra_customer_trx ct
                    WHERE ct.customer_trx_id   = p_customer_trx_id
                      AND ct.cust_trx_type_id  = ctt.cust_trx_type_id;
                    EXCEPTION
                    WHEN OTHERS THEN
                       RAISE;
                    END;
                    IF  (l_open_rec = 'Y' AND
                         l_ctt_type = 'CM' AND
                         l_previous_customer_trx_id IS NOT NULL)
                    THEN
                       DECLARE
                       CURSOR del_app_dist IS
                       SELECT app.receivable_application_id app_id,
                              app.customer_trx_id           trx_id
                         FROM    ar_receivable_applications app
                        WHERE  app.applied_customer_trx_id  = l_previous_customer_trx_id
                          AND  app.customer_trx_id = p_customer_trx_id
			  AND  app.posting_control_id = -3
                          AND  NVL(app.confirmed_flag,'Y') = 'Y'
                          AND  EXISTS (SELECT 'x'
                                       FROM  ar_distributions ard
                                       WHERE  ard.source_table = 'RA'
                                       AND  ard.source_id    = app.receivable_application_id);
                      BEGIN
                      FOR l_rec_del_app in del_app_dist LOOP
                         l_ae_doc_rec.document_type           := 'CREDIT_MEMO';
                         l_ae_doc_rec.document_id             := l_rec_del_app.trx_id;
                         l_ae_doc_rec.accounting_entity_level := 'ONE';
                         l_ae_doc_rec.source_table            := 'RA';
                         l_ae_doc_rec.source_id               := l_rec_del_app.app_id;
                         l_ae_doc_rec.source_id_old           := '';
                         l_ae_doc_rec.other_flag              := '';

                         l_ae_doc_rec.pay_sched_upd_yn        := 'Y';

                         arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
                         arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
                      END LOOP;
                      END;
                    END IF;
               END IF;

               p_backout_done_flag := FALSE;

      ELSE
           arp_ctlgd_pkg.fetch_p(l_old_dist_rec, p_cust_trx_line_gl_dist_id);

           IF  ( l_ccid_changed_flag = TRUE )
           THEN

  	        /*------------------------------------------------+
                 |  Insert 2 rows into ra_cust_trx_line_gl_dist   |
                 |       1. amount = -<db amount>,		  |
                 |          ccid = <db (old) ccid>		  |
                 |       2. amount = <displayed amount>,	  |
                 |          ccid = <new ccid>			  |
                 +------------------------------------------------*/

                backout_ccid(l_old_dist_rec,
                             p_dist_rec,
                             p_header_gl_date,
                             p_trx_date,
                             p_invoicing_rule_id,
                             p_exchange_rate,
                             p_currency_code,
                             p_precision,
                             p_mau);

                p_backout_done_flag := TRUE;

           ELSE IF (l_amount_percent_changed_flag = TRUE)
                THEN

    	            /*------------------------------------------------+
                     |  Insert one new row to backout the old amount. |
                     |  amount = <displayed amount> - <db amount>     |
                     +------------------------------------------------*/

                     backout_amount(l_old_dist_rec,
                                    p_dist_rec,
                                    p_header_gl_date,
                                    p_trx_date,
                                    p_invoicing_rule_id,
                                    p_exchange_rate,
                                    p_currency_code,
                                    p_precision,
                                    p_mau);

                     p_backout_done_flag := TRUE;

                ELSE

    	            /*--------------------------------------+
                     |  Do a simple update with no backout. |
                     |  Nothing of consequence has changed. |
                     +--------------------------------------*/

                     arp_util.debug('simple update - case 2');

                     arp_ctlgd_pkg.update_p(p_dist_rec,
                                            p_cust_trx_line_gl_dist_id,
                                            p_exchange_rate,
                                            p_currency_code,
                                            p_precision,
                                            p_mau);

                     p_backout_done_flag := FALSE;

                END IF;

           END IF;
      END IF;

       /*----------------------------------------------------+
        |  Validate tax from revenue account.                |
        +----------------------------------------------------*/
      val_tax_from_revenue( p_dist_rec );

--BUG#2750340
      --------------------------------------------------------------
      --  Need to call AR XLA events because when user update the
      --  a distribution directly through Trx WB, the distributions
      --  are created by this api.
      --  Call XLA event with the doc id to avoid missing any
      --  distributions unstamped
      --------------------------------------------------------------
      l_ev_rec.xla_from_doc_id   := p_dist_rec.customer_trx_id;
      l_ev_rec.xla_to_doc_id     := p_dist_rec.customer_trx_id;
      l_ev_rec.xla_req_id        := NULL;
      l_ev_rec.xla_doc_table     := 'CT';
      l_ev_rec.xla_doc_event     := NULL;
      l_ev_rec.xla_mode          := 'O';
      l_ev_rec.xla_call          := 'B';
      l_ev_rec.xla_fetch_size    := 999;
      arp_xla_events.create_events(p_xla_ev_rec => l_ev_rec );

     arp_util.debug('arp_process_dist.update_dist()-');

EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

    arp_util.debug('EXCEPTION:  arp_process_dist.update_dist()');
    arp_util.debug('---------- parameters for update_dist() ---------');
    arp_util.debug('p_form_name                 = ' || p_form_name);
    arp_util.debug('p_form_version              = ' || p_form_version);


    arp_util.debug('p_backout_flag              = ' ||
                             arp_trx_util.boolean_to_varchar2(p_backout_flag));

    arp_util.debug('p_cust_trx_line_gl_dist_id  = ' ||
                   p_cust_trx_line_gl_dist_id);

    arp_util.debug('p_customer_trx_id           = ' ||
                   p_customer_trx_id);

    arp_util.debug('p_header_gl_date            = ' || p_header_gl_date );
    arp_util.debug('p_trx_date                  = ' || p_trx_date);
    arp_util.debug('p_invoicing_rule_id         = ' || p_invoicing_rule_id);

    arp_util.debug('p_exchange_rate             = ' || p_exchange_rate);
    arp_util.debug('p_currency_code             = ' || p_currency_code);
    arp_util.debug('p_precision                 = ' || p_precision );
    arp_util.debug('p_mau                       = ' || p_mau );

    arp_ctlgd_pkg.display_dist_rec( p_dist_rec );

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_dist							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes a record fromra_cust_trx_line_gl_dist.			     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |		      p_cust_trx_line_gl_dist_id 			     |
 |		      p_customer_trx_id 				     |
 |		      p_dist_rec					     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE delete_dist(
           p_form_name                 IN varchar2,
           p_form_version              IN number,
           p_cust_trx_line_gl_dist_id  IN
                    ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id	       IN ra_customer_trx.customer_trx_id%type,
           p_dist_rec		       IN ra_cust_trx_line_gl_dist%rowtype)
                   IS


BEGIN

      arp_util.debug('arp_process_dist.delete_dist()+');

      /*----------------------------------------------+
       |   Check the form version to determine if it  |
       |   is compatible with the entity handler.     |
       +----------------------------------------------*/

      arp_trx_validate.ar_entity_version_check(p_form_name, p_form_version);

      /*-------------------------+
       |  Do required validation |
       +-------------------------*/

      arp_process_dist.val_delete_dist(p_dist_rec);

      /*----------------------------------------------------------------+
       | Lock rows in other tables that reference this customer_trx_id  |
       +----------------------------------------------------------------*/

      arp_trx_util.lock_transaction(p_customer_trx_id);

       /*----------------------------------------------------+
        |  call the table-handler to delete the dist record  |
        +----------------------------------------------------*/

      arp_ctlgd_pkg.delete_p( p_cust_trx_line_gl_dist_id );

       /*----------------------------------------------------+
        |  Validate tax from revenue account.                |
        +----------------------------------------------------*/
      val_tax_from_revenue( p_dist_rec );

      arp_util.debug('arp_process_dist.delete_dist()-');

EXCEPTION
 WHEN OTHERS THEN

   /*---------------------------------------------+
    |  Display parameters and raise the exception |
    +---------------------------------------------*/

    arp_util.debug('EXCEPTION:  arp_process_dist.delete_dist()');

    arp_util.debug('---------- delete_dist() ---------');

    arp_util.debug('p_form_name                  = ' || p_form_name);
    arp_util.debug('p_form_version               = ' || p_form_version);

    arp_util.debug('p_cust_trx_line_gl_dist_id  = ' ||
                   p_cust_trx_line_gl_dist_id);

    arp_ctlgd_pkg.display_dist_rec( p_dist_rec );

    RAISE;

END;


  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

   pg_number_dummy    := arp_ctlgd_pkg.get_number_dummy;

END ARP_PROCESS_DIST;

/
