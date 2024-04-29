--------------------------------------------------------
--  DDL for Package Body ARP_TRX_DEFAULTS_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_DEFAULTS_3" AS
/* $Header: ARTUDF3B.pls 120.27.12010000.7 2009/03/23 13:13:05 dgaurab ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


NULL_VAR address_rec_type;  /* Added for Oracle8 - bug460986 */
pg_text_dummy   varchar2(10);
pg_flag_dummy   varchar2(10);
pg_number_dummy number;
pg_date_dummy   date;

pg_base_curr_code          gl_sets_of_books.currency_code%type;
pg_base_precision          fnd_currencies.precision%type;
pg_base_min_acc_unit       fnd_currencies.minimum_accountable_unit%type;
pg_set_of_books_id         ar_system_parameters.set_of_books_id%type;

pg_remit_to_address_rec    address_rec_type         := NULL;
pg_payment_type_code       ar_receipt_methods.payment_type_code%type; --ajay bug 1081390

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_default_remit_to                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the default remit to address                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      None						     |
 |              OUT:                                                         |
 |                    p_remit_to_address_id                                  |
 |                    p_remit_to_address_rec                                 |
 |                                                                           |
 | NOTES                                                                     |
 |     The procedure produces a NO_DATA_FOUND error if no default remit to   |
 |     address has been set up.                                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE get_default_remit_to(
                                p_remit_to_address_id OUT NOCOPY
                                      NUMBER,
                                p_remit_to_address_rec OUT NOCOPY address_rec_type
                              ) IS


BEGIN

   arp_util.debug('arp_trx_defaults_3.get_default_remit_to()+');


  /*----------------------------------------------------------------+
   |  If the default remit to address has not been determined,      |
   |  get the default remit to address and cache it using package   |
   |  level variables.                                              |
   |  If the default remit to address has been determined,          |
   |  just use the cached values.                                   |
   +----------------------------------------------------------------*/

   IF pg_remit_to_address_rec.cust_acct_site_id IS NULL
   THEN

         arp_util.debug('selecting the default remit to address.');

         SELECT acct_site.cust_acct_site_id,
                loc.address1, loc.address2, loc.address3,
                loc.address4, loc.city, loc.state,
                loc.province, loc.postal_code,
                loc.country
         INTO   pg_remit_to_address_rec
         FROM   ra_remit_tos rt,
                hz_cust_acct_sites acct_site,
                hz_party_sites party_site,
                hz_locations loc
         WHERE  rt.state              = 'DEFAULT'
         AND    rt.country            = 'DEFAULT'
         AND    rt.address_id         = acct_site.cust_acct_site_id
         and    acct_site.party_site_id = party_site.party_site_id
         AND    loc.location_id = party_site.location_id
         AND    rt.status             = 'A'
         AND    NVL( acct_site.status, 'A' )  = 'A';

   ELSE
         arp_util.debug('getting the default remit to address from the cache');

   END IF;

   p_remit_to_address_id  :=  pg_remit_to_address_rec.cust_acct_site_id;
   p_remit_to_address_rec :=  pg_remit_to_address_rec;

   arp_util.debug(' ');
   arp_util.debug('The default remit to address is:');
   arp_util.debug('ID:           = ' || pg_remit_to_address_rec.cust_acct_site_id);
   arp_util.debug('address1:     = ' || pg_remit_to_address_rec.address1);
   arp_util.debug('address2:     = ' || pg_remit_to_address_rec.address2);
   arp_util.debug('address3:     = ' || pg_remit_to_address_rec.address3);
   arp_util.debug('address4:     = ' || pg_remit_to_address_rec.address4);
   arp_util.debug('city    :     = ' || pg_remit_to_address_rec.city);
   arp_util.debug('state   :     = ' || pg_remit_to_address_rec.state);
   arp_util.debug('provence:     = ' || pg_remit_to_address_rec.province);
   arp_util.debug('postal code:  = ' || pg_remit_to_address_rec.postal_code);
   arp_util.debug('country:      = ' || pg_remit_to_address_rec.country);
   arp_util.debug(' ');

   arp_util.debug('arp_trx_defaults_3.get_default_remit_to()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  arp_trx_defaults_3.get_default_remit_to()');
       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_remit_to_address                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the default remit to address                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_match_state                                          |
 |                    p_match_country                                        |
 |                    p_match_postal_code                                    |
 |                    p_match_address_id                                     |
 |                    p_match_site_use_id                                    |
 |              OUT:                                                         |
 |                    p_remit_to_address_id                                  |
 |                    p_remit_to_address_rec                                 |
 |                                                                           |
 | NOTES                                                                     |
 |     One of the three sets of parameters must be passed in:                |
 |       - p_match_state, p_match_country or p_match_postal_code             |
 |       - p_match_address_id                                                |
 |       - p_match_site use_id                                               |
 |                                                                           |
 |     The procedure produces a NO_DATA_FOUND error if no remit to address   |
 |     can be found.                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE get_remit_to_address(
                                p_match_state           IN
                                      hz_locations.state%type,
                                p_match_country         IN
                                      hz_locations.country%type,
                                p_match_postal_code     IN
                                      hz_locations.postal_code%type,
                                p_match_address_id      IN
                                      NUMBER,
                                p_match_site_use_id     IN
                                      NUMBER,
                                p_remit_to_address_id  OUT NOCOPY
                                      NUMBER,
                                p_remit_to_address_rec OUT NOCOPY
                                      address_rec_type
                              ) IS


    l_match_state            hz_locations.state%type;
    l_match_country          hz_locations.country%type;
    l_match_postal_code      hz_locations.postal_code%type;
    l_remit_to_address_rec   address_rec_type;

    /* BugFix:2107873 Modified the Following SELECT statement so that
    the Remit_to Country will be picked Up from fnd_territories_vl instead
    of from hz_locations */
    CURSOR remit_to IS
    SELECT acct_site.cust_acct_site_id,
           loc.address1, loc.address2,
           loc.address3, loc.address4,
           loc.city, loc.state,
           loc.province, loc.postal_code,
           territory.territory_short_name  --loc.country
    FROM   hz_cust_acct_sites acct_site,
           hz_party_sites party_site,
           hz_locations loc,
           fnd_territories_vl territory,
           ra_remit_tos  rt
    WHERE  NVL( acct_site.status, 'A' )  = 'A'
    AND    acct_site.cust_acct_site_id  = rt.address_id
    AND    acct_site.party_site_id = party_site.party_site_id
    AND    loc.location_id = party_site.location_id
    AND    rt.status             = 'A'
    AND    rt.country            = l_match_country
    AND    loc.country = territory.territory_code
    AND    (
                 l_match_state = NVL( rt.state, l_match_state )
             OR
                 (
                    l_match_state IS NULL   AND
                    rt.state      IS NULL
                 )
             OR  (
                    l_match_state IS NULL                               AND
                    l_match_postal_code <= NVL( rt.postal_code_high,
                                                l_match_postal_code )   AND
                    l_match_postal_code >= NVL( rt.postal_code_low,
                                                l_match_postal_code )   AND
                    (
                          postal_code_low  IS NOT NULL
                      OR  postal_code_high IS NOT NULL
                    )
                 )
           )
    AND    (
                 (
                     l_match_postal_code <= NVL( rt.postal_code_high,
                                                 l_match_postal_code )  AND
                     l_match_postal_code >= NVL( rt.postal_code_low,
                                                 l_match_postal_code )
                 )
             OR  (
                     l_match_postal_code IS NULL  AND
                     rt.postal_code_low  IS NULL  AND
                     rt.postal_code_high IS NULL
                 )
           )
    ORDER BY rt.state,
             rt.postal_code_low,
             rt.postal_code_high;


BEGIN

   arp_util.debug('arp_trx_defaults_3.get_remit_to_address()+');

  /*----------------------------------+
   |  Initialize the OUT NOCOPY parameters   |
   +----------------------------------*/

   p_remit_to_address_id   := null;
   p_remit_to_address_rec  := NULL_VAR; /* modified for Oracle8 -bug460986 */

  /*--------------------------------------------+
   |  Validate parameters to make sure that a   |
   |  valid match criteria has been specified.  |
   +--------------------------------------------*/

   IF (
         p_match_state         IS NULL  AND
         p_match_country       IS NULL  AND
         p_match_postal_code   IS NULL  AND
         p_match_address_id    IS NULL  AND
         p_match_site_use_id   IS NULL
      )
   THEN
         fnd_message.set_name('AR', 'AR_INV_ARGS');
         fnd_message.set_token('USER_EXIT',
                               'get_remit_to_address()');
         app_exception.raise_exception;
   END IF;

  /*-------------------------------------------------------------------------+
   | IF   the state, country or postal code to match to have been specified, |
   | THEN use those values.                                                  |
   | ELSE get the match values by selecting based on the address or          |
   |      the site use depending on which ID has been specified.             |
   +-------------------------------------------------------------------------*/

   IF (
         p_match_state     ||
         p_match_country   ||
         p_match_postal_code   IS NULL
      )
   THEN

        /*------------------------------------------+
         |  Get the address information to match    |
         |  if the address_id was specified         |
         +------------------------------------------*/

         IF  ( p_match_address_id IS NOT NULL )
         THEN

               arp_util.debug('getting address Info. based on address_id');

               SELECT loc.state,
                      loc.country,
                      loc.postal_code
               INTO   l_match_state,
                      l_match_country,
                      l_match_postal_code
               FROM   hz_cust_acct_sites acct_site,
                      hz_party_sites party_site,
                      hz_locations loc
               WHERE  acct_site.cust_acct_site_id = p_match_address_id
                 AND  acct_site.party_site_id = party_site.party_site_id
                 AND  loc.location_id = party_site.location_id;

         END IF;

        /*-------------------------------------------+
         |  Get the address information to match if  |
         |  the site_use_id was specified and the    |
         |  address_id was not specified             |
         +-------------------------------------------*/

         IF  ( p_match_site_use_id IS NOT NULL  AND
               p_match_address_id  IS NULL )
         THEN

               arp_util.debug('getting address Info. based on site_use_id');

               SELECT loc.state,
                      loc.country,
                      loc.postal_code
               INTO   l_match_state,
                      l_match_country,
                      l_match_postal_code
               FROM   hz_cust_acct_sites acct_site,
                      hz_party_sites party_site,
                      hz_locations loc,
                      hz_cust_site_uses   su
               WHERE  acct_site.cust_acct_site_id  = su.cust_acct_site_id
               AND    su.site_use_id = p_match_site_use_id
               AND    acct_site.party_site_id = party_site.party_site_id
               AND    loc.location_id = party_site.location_id;

         END IF;

   ELSE  -- match columns were specified case
         arp_util.debug('getting address Info. based on match values');

         l_match_state        := p_match_state;
         l_match_country      := p_match_country;
         l_match_postal_code  := p_match_postal_code;

   END IF;

  /*---------------------------------------------------------------+
   |  Select the remit to information based on the match criteria  |
   +---------------------------------------------------------------*/

   arp_util.debug('selecting remit to information');

   OPEN remit_to;

   FETCH  remit_to
   INTO  l_remit_to_address_rec;


  /*-------------------------------------------------------------+
   |  IF    no remit to address was selected above,              |
   |  THEN  use the default remit to address.                    |
   |                                                             |
   |  IF    no default remit to address exists,                  |
   |  THEN  the procedure will raise a NO_DATA_FOUND exception.  |
   +-------------------------------------------------------------*/

   IF ( remit_to%NOTFOUND )
   THEN

           get_default_remit_to(
                                  p_remit_to_address_id,
                                  l_remit_to_address_rec
                               );

           p_remit_to_address_rec := l_remit_to_address_rec;

   ELSE
           p_remit_to_address_id  := l_remit_to_address_rec.cust_acct_site_id;
           p_remit_to_address_rec := l_remit_to_address_rec;
   END IF;


   CLOSE remit_to;

   arp_util.debug(' ');
   arp_util.debug('The remit to address is:');
   arp_util.debug('ID:           = ' || l_remit_to_address_rec.cust_acct_site_id);
   arp_util.debug('address1:     = ' || l_remit_to_address_rec.address1);
   arp_util.debug('address2:     = ' || l_remit_to_address_rec.address2);
   arp_util.debug('address3:     = ' || l_remit_to_address_rec.address3);
   arp_util.debug('address4:     = ' || l_remit_to_address_rec.address4);
   arp_util.debug('city    :     = ' || l_remit_to_address_rec.city);
   arp_util.debug('state   :     = ' || l_remit_to_address_rec.state);
   arp_util.debug('provence:     = ' || l_remit_to_address_rec.province);
   arp_util.debug('postal code:  = ' || l_remit_to_address_rec.postal_code);
   arp_util.debug('country:      = ' || l_remit_to_address_rec.country);
   arp_util.debug(' ');

   arp_util.debug('arp_trx_defaults_3.get_remit_to_address()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  arp_trx_defaults_3.get_remit_to_address()');

        arp_util.debug('---------- ' ||
                'Parameters for arp_trx_defaults_3.get_remit_to_address() ' ||
                       '---------- ');

        arp_util.debug('p_match_state         : ' || p_match_state );
        arp_util.debug('p_match_country       : ' || p_match_country );
        arp_util.debug('p_match_postal_code   : ' || p_match_postal_code );
        arp_util.debug('p_match_address_id    : ' || p_match_address_id );
        arp_util.debug('p_match_site_use_id   : ' || p_match_site_use_id );


	/*-----------------------------------------------------------+
        |  Close the cursor, but don't raise an error if the close   |
        |  fails. The original error will be raised in this case.    |
	+------------------------------------------------------------*/

        BEGIN
           CLOSE remit_to;
        EXCEPTION
           WHEN OTHERS THEN null;
        END;

        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_payment_method                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if a potential default payment method is valid.             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                                              |
 |                   p_customer_id                                           |
 |                   p_site_use_id                                           |
 |                   p_currency_code                                         |
 |              OUT:                                                         |
 |                   p_payment_method_name                                   |
 |                   p_receipt_method_id                                     |
 |                   p_creation_method_code                                  |
 |                                                                           |
 | RETURNS    : TRUE if valid, FALSE otherwise                               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-NOV-95  Charlie Tomberg     Created                                |
 |     26-DEC-97  Debbie Jancis       Fixed Bug 602458.  Altered defaulting  |
 |                                    to check if payment method is          |
 |                                    automatic then a check is performed to |
 |                                    make sure that there is a bank acct for|
 |                                    entered currency. If not, nothing is   |
 |                                    defaulted.                             |
 +===========================================================================*/


FUNCTION check_payment_method(
                               p_trx_date               IN
                                     ra_customer_trx.trx_date%type,
                               p_customer_id            IN
                                     ra_customer_trx.customer_trx_id%type,
                               p_site_use_id            IN
                                     hz_cust_site_uses.site_use_id%type,
                               p_currency_code          IN
                                     fnd_currencies.currency_code%type,
                               p_payment_method_name   OUT NOCOPY
                                     ar_receipt_methods.name%type,
                               p_receipt_method_id     OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
                               p_creation_method_code  OUT NOCOPY
                                   ar_receipt_classes.creation_method_code%type
                             ) RETURN BOOLEAN IS

  CURSOR payment_method_cur IS
   SELECT arm.name payment_method_name,
          arm.receipt_method_id,
          arm.payment_channel_code,  --ajay bug 1081390
          arc.creation_method_code
   FROM      ar_receipt_methods         arm,
             ra_cust_receipt_methods    rcrm,
             ar_receipt_method_accounts arma,
             ce_bank_acct_uses_all       aba,
             ce_bank_accounts            cba,
             ar_receipt_classes         arc,
	     ce_bank_branches_v		 bp  /*Bug3348454*/
   WHERE     arm.receipt_method_id = rcrm.receipt_method_id
   AND       arm.receipt_method_id = arma.receipt_method_id
   AND       arm.receipt_class_id  = arc.receipt_class_id
   AND       rcrm.customer_id      = p_customer_id
   AND       arma.org_id           = aba.org_id
   AND       arma.remit_bank_acct_use_id = aba.bank_acct_use_id
   AND       aba.bank_account_id = cba.bank_account_id
   AND	     bp.branch_party_id = cba.bank_branch_id  /*Bug3348454*/
   AND       p_trx_date <= NVL(bp.end_date,p_trx_date) /*Bug3348454*/
   AND
             (
/* Bug-3770337-PM - Remove NVl condition */
                 rcrm.site_use_id   = p_site_use_id
               OR
                 (
                        p_site_use_id     IS NULL
                   AND  rcrm.site_use_id  IS NULL
                 )
             )
   AND       rcrm.primary_flag          = 'Y'
   AND       (
                 cba.currency_code    =
                             p_currency_code  OR
                 cba.receipt_multi_currency_flag = 'Y'
             )

--  added following condition for Bug 602458:
--Removing the join condition based on currency_code as part of bug fix 5346710

  /*AND     ( arc.creation_method_code = 'MANUAL' or
            ( arc.creation_method_code = 'AUTOMATIC' and
              p_currency_code in (
				  select currency_code from
                                  IBY_FNDCPT_PAYER_ASSGN_INSTR_V
                                  where party_id = get_party_id(p_customer_id)
				  ))*/
   -- AND       aba.set_of_books_id = pg_set_of_books_id

   /*Bug3348454*/
   /*AND       TRUNC(nvl(aba.end_date,
                         p_trx_date)) >=
             TRUNC(p_trx_date)*/

   AND       TRUNC(nvl(cba.end_date,p_trx_date+1)) > TRUNC(p_trx_date)

   AND       p_trx_date between
                      TRUNC(nvl(
                                   arm.start_date,
                                  p_trx_date))
                  and TRUNC(nvl(
                                  arm.end_date,
                                  p_trx_date))
   AND       p_trx_date between
                      TRUNC(nvl(
                                   rcrm.start_date,
                                  p_trx_date))
                  and TRUNC(nvl(
                                  rcrm.end_date,
                                  p_trx_date))
   AND       p_trx_date between
                      TRUNC(arma.start_date)
                  and TRUNC(nvl(
                                  arma.end_date,
                                  p_trx_date))
/* 19-APR-2000 J Rautiainen BR Implementation. Added union to default BR
 * payment method. */
UNION
   SELECT    arm.name payment_method_name,
             arm.receipt_method_id,
             arm.payment_channel_code,
             arc.creation_method_code
   FROM      ar_receipt_methods         arm,
             ra_cust_receipt_methods    rcrm,
             ar_receipt_classes         arc,
             ar_system_parameters       sys
   WHERE     arm.receipt_method_id = rcrm.receipt_method_id
   AND       arm.receipt_class_id  = arc.receipt_class_id
   AND       arc.creation_method_code = 'BR'
   AND       NVL(sys.bills_receivable_enabled_flag,'N') = 'Y'
   AND       rcrm.customer_id      = p_customer_id
   AND
             (
/* Bug-3770337-PM - Remove NVl condition */
                 rcrm.site_use_id     = p_site_use_id
               OR
                 (
                        p_site_use_id     IS NULL
                   AND  rcrm.site_use_id  IS NULL
                 )
             )
   AND       rcrm.primary_flag          = 'Y'
   AND       p_trx_date between
                      TRUNC(nvl(
                                   arm.start_date,
                                  p_trx_date))
                  and TRUNC(nvl(
                                  arm.end_date,
                                  p_trx_date))
   AND       p_trx_date between
                      TRUNC(nvl(
                                   rcrm.start_date,
                                  p_trx_date))
                  and TRUNC(nvl(
                                  rcrm.end_date,
                                  p_trx_date));

   l_payment_method_name   ar_receipt_methods.name%type;
   l_receipt_method_id     ar_receipt_methods.receipt_method_id%type;
   l_creation_method_code  ar_receipt_classes.creation_method_code%type;
   payment_method_rec      payment_method_cur%ROWTYPE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.check_payment_method()+');
   END IF;

  /* 19-APR-2000 J Rautiainen BR Implementation.
   * Moved select statement to cursor. Also removed NO_DATA_FOUND
   * Exception handler and added the logic in the IF statement below */

   OPEN payment_method_cur;
   FETCH payment_method_cur INTO payment_method_rec;

   IF payment_method_cur%NOTFOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('check_payment_method: ' || 'return value: FALSE');
      END IF;
      CLOSE payment_method_cur;
      RETURN(FALSE);
   END IF;

   CLOSE payment_method_cur;

   l_payment_method_name  := payment_method_rec.payment_method_name;
   l_receipt_method_id    := payment_method_rec.receipt_method_id;
   l_creation_method_code := payment_method_rec.creation_method_code;
   p_payment_method_name  := payment_method_rec.payment_method_name;
   p_receipt_method_id    := payment_method_rec.receipt_method_id;
   p_creation_method_code := payment_method_rec.creation_method_code;
   pg_payment_type_code   := payment_method_rec.payment_channel_code;  --ajay bug 1081390

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('check_payment_method: ' || 'p_payment_method_name   = ' || l_payment_method_name );
      arp_util.debug('check_payment_method: ' || 'p_receipt_method_id     = ' ||
                                               TO_CHAR(l_receipt_method_id ) );
      arp_util.debug('check_payment_method: ' || 'p_creation_method_code  = ' || l_creation_method_code );
      arp_util.debug('check_payment_method: ' || 'return value            = TRUE');
      arp_util.debug('arp_trx_defaults_3.check_payment_method()-');
   END IF;


   return(TRUE);

EXCEPTION

    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('check_payment_method: ' ||
                'EXCEPTION:  arp_trx_defaults_3.check_payment_method()');
         arp_util.debug('------- parameters for check_payment_method ----');
         arp_util.debug('check_payment_method: ' || 'p_trx_date       = ' || TO_CHAR(p_trx_date) );
         arp_util.debug('check_payment_method: ' || 'p_customer_id    = ' || TO_CHAR(p_customer_id) );
         arp_util.debug('check_payment_method: ' || 'p_site_use_id    = ' || TO_CHAR(p_site_use_id) );
         arp_util.debug('check_payment_method: ' || 'p_currency_code  = ' || p_currency_code );
      END IF;

      RAISE;

END check_payment_method;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_bank default                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if a potential default bank is valid.                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                                              |
 |                   p_customer_id                                           |
 |                   p_site_use_id                                           |
 |                   p_currency_code                                         |
 |              OUT:                                                         |
 |                   p_customer_bank_account_id                              |
 |                   p_bank_account_num                                      |
 |                   p_bank_name                                             |
 |                   p_bank_branch_name                                      |
 |                   p_bank_branch_id                                        |
 |                                                                           |
 | RETURNS    : TRUE if valid, FALSE otherwise                               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-NOV-95  Charlie Tomberg     Created                                |
 |     16-AUG-99  Debbie Jancis       Acct masking project. Modified select  |
 |                                    to get masked bank acct num if profile |
 |                                    is set.                                |
 +===========================================================================*/

FUNCTION check_bank_default(
                               p_trx_date                   IN
                                     ra_customer_trx.trx_date%type,
                               p_customer_id                IN
                                     ra_customer_trx.customer_trx_id%type,
                               p_site_use_id                IN
                                     hz_cust_site_uses.site_use_id%type,
                               p_currency_code              IN
                                     fnd_currencies.currency_code%type,
                               p_customer_bank_account_id  OUT NOCOPY
                          ce_bank_accounts.bank_account_id%type,
                               p_bank_account_num          OUT NOCOPY
                                      ce_bank_accounts.bank_account_num%type,
                               p_bank_name                 OUT NOCOPY
                                      ce_bank_branches_v.bank_name%type,
                               p_bank_branch_name          OUT NOCOPY
                                      ce_bank_branches_v.bank_branch_name%type,
                               p_bank_branch_id            OUT NOCOPY
                                      ce_bank_branches_v.branch_party_id%TYPE
                             ) RETURN BOOLEAN IS


    l_customer_bank_account_id
                            ce_bank_accounts.bank_account_id%type;
    l_bank_account_num          ce_bank_accounts.bank_account_num%type;
    l_bank_name                 ce_bank_branches_v.bank_name%type;
    l_bank_branch_name          ce_bank_branches_v.bank_branch_name%type;
    l_bank_branch_id            ce_bank_branches_v.branch_party_id%TYPE;


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.check_bank_default()+');
   END IF;
/* PAYMENT UPTAKE removed the code to default the bank_account */

   return(TRUE);


END check_bank_default;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_payment_method_default                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the default payment method.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                                              |
 |                   p_currency_code                                         |
 |                   p_paying_customer_id                                    |
 |                   p_paying_site_use_id                                    |
 |                   p_bill_to_customer_id                                   |
 |                   p_bill_to_site_use_id                                   |
 |              OUT:                                                         |
 |                   p_payment_method_name                                   |
 |                   p_receipt_method_id                                     |
 |                   p_creation_method_code                                  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-NOV-95  Charlie Tomberg     Created                                |
 |     06-OCT-04  Surendra Rajan      Modified for bug-3770337               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_payment_method_default(
                                      p_trx_date               IN
                                            ra_customer_trx.trx_date%type,
                                      p_currency_code          IN
                                            fnd_currencies.currency_code%type,
                                      p_paying_customer_id     IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_paying_site_use_id     IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_bill_to_customer_id    IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_bill_to_site_use_id    IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_payment_method_name   OUT NOCOPY
                                            ar_receipt_methods.name%type,
                                      p_receipt_method_id     OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
                                      p_creation_method_code  OUT NOCOPY
                                   ar_receipt_classes.creation_method_code%type,
                                      p_trx_manual_flag        IN VARCHAR2    DEFAULT 'N'
                          ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_payment_method_default()+');
   END IF;


  /*-----------------------------------------------------------------+
   |  Check the parameters to make sure that defaulting is possible  |
   +-----------------------------------------------------------------*/

   IF (
           p_trx_date               IS NULL
       OR  p_currency_code          IS NULL
       OR  p_paying_customer_id  ||
           p_paying_site_use_id  ||
           p_bill_to_customer_id ||
           p_bill_to_site_use_id    IS NULL
      )
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Invalid parameters for get_payment_method_default()');
        END IF;
        RETURN;
   END IF;

  /*----------------------------------------------------------------+
   |  User creates a transaction in transaction form then the       |
   |  payment method will default from the primary payment method   |
   |  of the paying site use otherwise  (Ref. Bug-3770337)          |
   |  Default in the payment method using the following hierarchy:  |
   |    1) Primary payment method of the paying site use            |
   |    2) Primary payment method of the paying customer            |
   |    3) Primary payment method of the bill to site use           |
   |    4) Primary payment method of the bill to customer           |
   +----------------------------------------------------------------*/
   IF ( p_paying_site_use_id IS NOT NULL )
   THEN
      IF (check_payment_method(
                               p_trx_date,
                               p_paying_customer_id,
                               p_paying_site_use_id,
                               p_currency_code,
                               p_payment_method_name,
                               p_receipt_method_id,
                               p_creation_method_code
                             ) = TRUE )
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_payment_method_default: ' ||
                       'Defaulting payment method from: Paying Customer Site');
          END IF;
          RETURN;
      END IF;
   END IF;


   IF (check_payment_method(
                               p_trx_date,
                               p_paying_customer_id,
                               NULL,
                               p_currency_code,
                               p_payment_method_name,
                               p_receipt_method_id,
                               p_creation_method_code
                             ) = TRUE )
   THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_payment_method_default: ' ||  'Defaulting payment method from: Paying Customer');
          END IF;
          RETURN;
   END IF;

/* Bug-3770337-PM - Added below IF statement */
/*Bug 5208067   Moved the below IF statement from previous IF (to check payment method at
   billto customer header level) to this IF */
IF p_trx_manual_flag = 'N'  THEN

   IF ( NVL(p_bill_to_customer_id,-1) <> NVL(p_paying_customer_id,-1) AND
        NVL(p_bill_to_site_use_id,-1) <> NVL(p_paying_site_use_id,-1) AND
        p_bill_to_site_use_id IS NOT NULL
      )
   THEN
      IF (check_payment_method(
                               p_trx_date,
                               p_bill_to_customer_id,
                               p_bill_to_site_use_id,
                               p_currency_code,
                               p_payment_method_name,
                               p_receipt_method_id,
                               p_creation_method_code
                             ) = TRUE )
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_payment_method_default: ' ||
                      'Defaulting payment method from: Bill To Customer Site');
          END IF;

          RETURN;
      END IF;
   END IF;

   IF ( NVL(p_bill_to_customer_id,-1) <> NVL(p_paying_customer_id,-1) )
   THEN
      IF (check_payment_method(
                               p_trx_date,
                               p_bill_to_customer_id,
                               NULL,
                               p_currency_code,
                               p_payment_method_name,
                               p_receipt_method_id,
                               p_creation_method_code
                             ) = TRUE )
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_payment_method_default: ' || 'Defaulting payment method from: Bill To Customer');
          END IF;
          RETURN;
      END IF;
   END IF;
END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_payment_method_default()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_payment_method_default: ' ||
            'EXCEPTION:  arp_trx_defaults_3.get_payment_method_default()');
         arp_util.debug('get_payment_method_default: ' ||
            '------- parameters for get_payment_method_default ----');
         arp_util.debug('get_payment_method_default: ' || 'p_trx_date              = ' || TO_CHAR(p_trx_date) );
         arp_util.debug('get_payment_method_default: ' || 'p_currency_code         = ' || p_currency_code );
         arp_util.debug('get_payment_method_default: ' || 'p_paying_customer_id    = ' || p_paying_customer_id );
         arp_util.debug('get_payment_method_default: ' || 'p_paying_site_use_id    = ' || p_paying_site_use_id );
         arp_util.debug('get_payment_method_default: ' || 'p_bill_to_customer_id   = ' || p_bill_to_customer_id );
         arp_util.debug('get_payment_method_default: ' || 'p_bill_to_site_use_id   = ' || p_bill_to_site_use_id );
      END IF;

      RAISE;

END get_payment_method_default;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_bank_defaults                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the default payment method.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                                              |
 |                   p_currency_code                                         |
 |                   p_paying_customer_id                                    |
 |                   p_paying_site_use_id                                    |
 |                   p_bill_to_customer_id                                   |
 |                   p_bill_to_site_use_id                                   |
 |                   p_payment_type_code                                     |
 |              OUT:                                                         |
 |                   p_customer_bank_account_id                              |
 |                   p_bank_account_num                                      |
 |                   p_bank_name                                             |
 |                   p_bank_branch_name                                      |
 |                   p_bank_branch_id                                        |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-NOV-95  Charlie Tomberg     Created                                |
 |     06-OCT-04  Surendra Rajan      Modified for bug-3770337               |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_bank_defaults(
                               p_trx_date               IN
                                  ra_customer_trx.trx_date%type,
                               p_currency_code          IN
                                  fnd_currencies.currency_code%type,
                               p_paying_customer_id     IN
                                  hz_cust_accounts.cust_account_id%type,
                               p_paying_site_use_id     IN
                                  hz_cust_site_uses.site_use_id%type,
                               p_bill_to_customer_id    IN
                                  hz_cust_accounts.cust_account_id%type,
                               p_bill_to_site_use_id    IN
                                  hz_cust_site_uses.site_use_id%type,
                               p_payment_type_code      IN
                                  ar_receipt_methods.payment_type_code%type,
                               p_customer_bank_account_id  OUT NOCOPY
                           ce_bank_accounts.bank_account_id%type,
                               p_bank_account_num          OUT NOCOPY
                                  ce_bank_accounts.bank_account_num%type,
                               p_bank_name                 OUT NOCOPY
                                  ce_bank_branches_v.bank_name%type,
                               p_bank_branch_name          OUT NOCOPY
                                  ce_bank_branches_v.bank_branch_name%type,
                               p_bank_branch_id            OUT NOCOPY
                                  ce_bank_branches_v.branch_party_id%TYPE,
                               p_trx_manual_flag        IN VARCHAR2    DEFAULT 'N'
                          ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_bank_defaults()+');
   END IF;


  /*-----------------------------------------------------------------+
   |  Check the parameters to make sure that defaulting is possible  |
   +-----------------------------------------------------------------*/

   IF (
           p_trx_date               IS NULL
       OR  p_currency_code          IS NULL
       OR  p_paying_customer_id  ||
           p_paying_site_use_id  ||
           p_bill_to_customer_id ||
           p_bill_to_site_use_id    IS NULL
      )
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Invalid parameters for get_bank_defaults()');
        END IF;
        RETURN;
   END IF;

  /*  check first to see if the payment type is a credit card.  If it
      is then we want to default bank_name and branch_name fields
      from ce_bank_branches_v..  */

  IF ( NVL(p_payment_type_code,'-1') = 'CREDIT_CARD' ) THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('get_bank_defaults: ' || 'Defaulting parameters for Credit Card Type ');
     END IF;

     SELECT abb.bank_name,
            abb.bank_branch_name,
            abb.branch_party_id
     INTO
            p_bank_name,
            p_bank_branch_name,
            p_bank_branch_id
     FROM
            ce_bank_branches_v abb
     WHERE
            abb.branch_party_id = arp_global.CC_BANK_BRANCH_ID;

     RETURN;
  END IF;

  /*------------------------------------------------------------------+
   |  User creates a transaction in transaction form then the bank    |
   |  information will default from the primary bank of the paying    |
   |  site use otherwise  (Ref. Bug-3770337)                          |
   |  Default in the bank information using the following hierarchy:  |
   |    1) Primary bank of the paying site use                        |
   |    2) Primary bank of the paying customer                        |
   |    3) Primary bank of the bill to site use                       |
   |    4) Primary bank of the bill to customer                       |
   +------------------------------------------------------------------*/

   IF ( p_paying_site_use_id IS NOT NULL )
   THEN
      IF (check_bank_default(
                               p_trx_date,
                               p_paying_customer_id,
                               p_paying_site_use_id,
                               p_currency_code,
                               p_customer_bank_account_id,
                               p_bank_account_num,
                               p_bank_name,
                               p_bank_branch_name,
                               p_bank_branch_id
                          ) = TRUE )
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_bank_defaults: ' ||
                       'Defaulting bank from: Paying Customer Site');
          END IF;
          RETURN;
      END IF;
   END IF;

   IF (check_bank_default(
                               p_trx_date,
                               p_paying_customer_id,
                               NULL,
                               p_currency_code,
                               p_customer_bank_account_id,
                               p_bank_account_num,
                               p_bank_name,
                               p_bank_branch_name,
                               p_bank_branch_id
                             ) = TRUE )
   THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_bank_defaults: ' ||  'Defaulting bank from: Paying Customer');
          END IF;
          RETURN;
   END IF;

   /* Bug-3770337-PM - Added below IF statement */
   /*Moved this if here - Bug 5444390*/

IF p_trx_manual_flag = 'N'  THEN
   IF ( NVL(p_bill_to_customer_id,-1) <> NVL(p_paying_customer_id,-1) AND
        NVL(p_bill_to_site_use_id,-1) <> NVL(p_paying_site_use_id,-1) AND
        p_bill_to_site_use_id IS NOT NULL
      )
   THEN
      IF (check_bank_default(
                               p_trx_date,
                               p_bill_to_customer_id,
                               p_bill_to_site_use_id,
                               p_currency_code,
                               p_customer_bank_account_id,
                               p_bank_account_num,
                               p_bank_name,
                               p_bank_branch_name,
                               p_bank_branch_id
                             ) = TRUE )
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_bank_defaults: ' ||
                      'Defaulting bank from: Bill To Customer Site');
          END IF;

          RETURN;
      END IF;
   END IF;

   IF ( NVL(p_bill_to_customer_id,-1) <> NVL(p_paying_customer_id,-1) )
   THEN
      IF (check_bank_default(
                               p_trx_date,
                               p_bill_to_customer_id,
                               NULL,
                               p_currency_code,
                               p_customer_bank_account_id,
                               p_bank_account_num,
                               p_bank_name,
                               p_bank_branch_name,
                               p_bank_branch_id
                             ) = TRUE )
      THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_bank_defaults: ' || 'Defaulting bank from: Bill To Customer');
          END IF;
          RETURN;
      END IF;
   END IF;
END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_bank_defaults()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_bank_defaults: ' ||
            'EXCEPTION:  arp_trx_defaults_3.get_bank_defaults()');
         arp_util.debug('get_bank_defaults: ' ||
            '------- parameters for get_bank_defaults ----');
         arp_util.debug('get_bank_defaults: ' || 'p_trx_date              = ' || TO_CHAR(p_trx_date) );
         arp_util.debug('get_bank_defaults: ' || 'p_currency_code         = ' || p_currency_code );
         arp_util.debug('get_bank_defaults: ' || 'p_paying_customer_id    = ' || p_paying_customer_id );
         arp_util.debug('get_bank_defaults: ' || 'p_paying_site_use_id    = ' || p_paying_site_use_id );
         arp_util.debug('get_bank_defaults: ' || 'p_bill_to_customer_id   = ' || p_bill_to_customer_id );
         arp_util.debug('get_bank_defaults: ' || 'p_bill_to_site_use_id   = ' || p_bill_to_site_use_id );
      END IF;

      RAISE;

END get_bank_defaults;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_bank_defaults                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the default payment method.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                                              |
 |                   p_currency_code                                         |
 |                   p_paying_customer_id                                    |
 |                   p_paying_site_use_id                                    |
 |                   p_bill_to_customer_id                                   |
 |                   p_bill_to_site_use_id                                   |
 |              OUT:                                                         |
 |                   p_customer_bank_account_id                              |
 |                   p_bank_account_num                                      |
 |                   p_bank_name                                             |
 |                   p_bank_branch_name                                      |
 |                   p_bank_branch_id                                        |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     21-NOV-95  Charlie Tomberg     Created                                |
 |     23-JUN-99  Ajay Pandit	      Modified the procedure for fixing      |
 |                                    bug no 913071 so that bank info. is    |
 |                                    not defaulted( rather assigned NULL    |
 |                                    values) when the payment method is     |
 |                                    MANUAL                                 |
 +===========================================================================*/

PROCEDURE get_pay_method_and_bank_deflts(
                                      p_trx_date                   IN
                                            ra_customer_trx.trx_date%type,
                                      p_currency_code              IN
                                            fnd_currencies.currency_code%type,
                                      p_paying_customer_id         IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_paying_site_use_id         IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_bill_to_customer_id        IN
                                            hz_cust_accounts.cust_account_id%type,
                                      p_bill_to_site_use_id        IN
                                            hz_cust_site_uses.site_use_id%type,
                                      p_payment_type_code      IN
                                  ar_receipt_methods.payment_type_code%type,
                                      p_payment_method_name       OUT NOCOPY
                                            ar_receipt_methods.name%type,
                                      p_receipt_method_id         OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
                                      p_creation_method_code      OUT NOCOPY
                                  ar_receipt_classes.creation_method_code%type,
                                      p_customer_bank_account_id  OUT NOCOPY
                           ce_bank_accounts.bank_account_id%type,
                                      p_bank_account_num          OUT NOCOPY
                                        ce_bank_accounts.bank_account_num%type,
                                      p_bank_name                 OUT NOCOPY
                                             ce_bank_branches_v.bank_name%type,
                                      p_bank_branch_name          OUT NOCOPY
                                        ce_bank_branches_v.bank_branch_name%type,
                                      p_bank_branch_id            OUT NOCOPY
                                          ce_bank_branches_v.branch_party_id%TYPE,
                                      p_trx_manual_flag        IN VARCHAR2    DEFAULT 'N'
                          ) IS


BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('get_pay_method_and_bank_deflts: ' || 'arp_trx_defaults_3.get_pay_method_and_bank_deflt()+');
      arp_util.debug('get_pay_method_and_bank_deflts: ' || 'calling get_payment_method_default()');
   END IF;
   get_payment_method_default(
                               p_trx_date,
                               p_currency_code,
                               p_paying_customer_id,
                               p_paying_site_use_id,
                               p_bill_to_customer_id,
                               p_bill_to_site_use_id,
                               p_payment_method_name,
                               p_receipt_method_id,
                               p_creation_method_code,
                               p_trx_manual_flag              /* Bug-3770337-PM */
                             );
/*Fix for Bug 913072 */
   IF (p_creation_method_code = 'MANUAL' or p_creation_method_code IS NULL) THEN /*Bug 3312212*/
     p_customer_bank_account_id := NULL;
     p_bank_account_num := NULL;
     p_bank_name  := NULL;
     p_bank_branch_name := NULL;
     p_bank_branch_id := NULL;
   ELSE

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('get_pay_method_and_bank_deflts: ' || 'calling get_bank_defaults()');
   END IF;
   get_bank_defaults(
                               p_trx_date,
                               p_currency_code,
                               p_paying_customer_id,
                               p_paying_site_use_id,
                               p_bill_to_customer_id,
                               p_bill_to_site_use_id,
                               pg_payment_type_code, --ajay bug 1081390
                               p_customer_bank_account_id,
                               p_bank_account_num,
                               p_bank_name,
                               p_bank_branch_name,
                               p_bank_branch_id,
                               p_trx_manual_flag              /* Bug-3770337-PM */
                          );
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('get_pay_method_and_bank_deflts: ' || 'arp_trx_defaults_3.get_pay_method_and_bank_deflt()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_pay_method_and_bank_deflts: ' ||
            'EXCEPTION:  arp_trx_defaults_3.get_pay_method_and_bank_deflt()');
         arp_util.debug('get_pay_method_and_bank_deflts: ' ||
            '------- parameters for get_pay_method_and_bank_deflt ----');
         arp_util.debug('get_pay_method_and_bank_deflts: ' || 'p_trx_date              = ' || TO_CHAR(p_trx_date) );
         arp_util.debug('get_pay_method_and_bank_deflts: ' || 'p_currency_code         = ' || p_currency_code );
         arp_util.debug('get_pay_method_and_bank_deflts: ' || 'p_paying_customer_id    = ' || p_paying_customer_id );
         arp_util.debug('get_pay_method_and_bank_deflts: ' || 'p_paying_site_use_id    = ' || p_paying_site_use_id );
         arp_util.debug('get_pay_method_and_bank_deflts: ' || 'p_bill_to_customer_id   = ' || p_bill_to_customer_id );
         arp_util.debug('get_pay_method_and_bank_deflts: ' || 'p_bill_to_site_use_id   = ' || p_bill_to_site_use_id );
      END IF;

      RAISE;

END get_pay_method_and_bank_deflts;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_remit_to_default                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the default remit to address.                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_state                                                  |
 |                  p_postal_code                                            |
 |                  p_country                                                |
 |              OUT:                                                         |
 |                  p_address_id                                             |
 |                  p_address1                                               |
 |                  p_address2                                               |
 |                  p_address3                                               |
 |                  p_concatenated_address                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_remit_to_default(
                              p_state        IN  hz_locations.state%type,
                              p_postal_code  IN  hz_locations.postal_code%type,
                              p_country      IN  hz_locations.country%type,
                              p_address_id   OUT NOCOPY  NUMBER,
                              p_address1     OUT NOCOPY  hz_locations.address1%type,
                              p_address2     OUT NOCOPY  hz_locations.address2%type,
                              p_address3     OUT NOCOPY  varchar2,
                              p_concatenated_address OUT NOCOPY varchar2
                          ) IS

   l_remit_to_address_rec address_rec_type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_remit_to_default()+');
   END IF;


   BEGIN
        arp_trx_defaults_3.get_remit_to_address(
                                           p_state,
                                           p_country,
                                           p_postal_code,
                                           NULL,
                                           NULL,
                                           p_address_id,
                                           l_remit_to_address_rec
                                         );

        p_address1 := l_remit_to_address_rec.address1;

        p_address2 := l_remit_to_address_rec.address2;

        p_address3 := l_remit_to_address_rec.city || ',' || ' ' ||
                      NVL(l_remit_to_address_rec.state,
                          l_remit_to_address_rec.province)
                          ||' '|| l_remit_to_address_rec.postal_code||
                          ' ' || l_remit_to_address_rec.country;

        SELECT SUBSTRB( l_remit_to_address_rec.address1,
                        1, 25) ||
               DECODE( l_remit_to_address_rec.address2,
                       NULL, NULL,
                             ', ') ||
               NVL(
                     SUBSTRB( l_remit_to_address_rec.address2,
                              1, 25),
                     SUBSTRB( l_remit_to_address_rec.address1,
                              26, 25)
                  ) || ','||' '||
               l_remit_to_address_rec.city ||
               ','||' '||
               NVL( l_remit_to_address_rec.state,
                    l_remit_to_address_rec.province) ||
               ' '||  l_remit_to_address_rec.postal_code ||
               ' '||  l_remit_to_address_rec.country
        INTO p_concatenated_address
        FROM dual;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          p_address_id           := NULL;
          p_address1             := NULL;
          p_address2             := NULL;
          p_address3             := NULL;
          p_concatenated_address := NULL;

      WHEN OTHERS THEN RAISE;
   END;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_remit_to_default()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('EXCEPTION:  arp_trx_defaults_3.get_remit_to_default()');
          arp_util.debug('------- parameters for get_remit_to_default ----');
          arp_util.debug('get_remit_to_default: ' || 'p_state        = ' || p_state);
          arp_util.debug('get_remit_to_default: ' || 'p_postal_code  = ' || p_postal_code);
          arp_util.debug('get_remit_to_default: ' || 'p_countrye     = ' || p_country);
       END IF;

       RAISE;

END get_remit_to_default;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_term_default                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines and returns the term default and realted other items.       |
 |    The term defaults to the first valid term found in the following list: |
 |     - The customer's bill to site use record                              |
 |     - The customer's site level profile                                   |
 |     - The customer's customer level profile                               |
 |     - The transaction type                                                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_term_id                                               |
 |                   p_type_term_id                                          |
 |                   p_type_term_name                                        |
 |                   p_customer_id                                           |
 |                   p_site_use_id                                           |
 |                   p_trx_date                                              |
 |                   p_class                                                 |
 |              OUT:                                                         |
 |                   p_default_term_id                                       |
 |                   p_default_term_name                                     |
 |                   p_number_of_due_dates                                   |
 |                   p_term_due_date                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_term_default(
                             p_term_id        IN ra_terms.term_id%type,
                             p_type_term_id   IN ra_terms.term_id%type,
                             p_type_term_name IN ra_terms.name%type,
                             p_customer_id    IN hz_cust_accounts.cust_account_id%type,
                             p_site_use_id    IN hz_cust_site_uses.site_use_id%type,
                             p_trx_date       IN ra_customer_trx.trx_date%type,
                             p_class          IN ra_cust_trx_types.type%type,
                             p_cust_trx_type_id          IN ra_cust_trx_types.cust_trx_type_id%type,
                             p_default_term_id      OUT NOCOPY ra_terms.term_id%type,
                             p_default_term_name    OUT NOCOPY ra_terms.name%type,
                             p_number_of_due_dates  OUT NOCOPY number,
                             p_term_due_date        OUT NOCOPY
                                   ra_customer_trx.term_due_date%type
                          ) IS

   l_number_of_due_dates number;
   l_term_due_date       ra_customer_trx.term_due_date%type;
   l_cust_term_id        ra_terms.term_id%type;
   l_cust_term_name      ra_terms.name%type;
   l_org_id              ra_customer_trx.org_id%type;
   l_billing_cycle_id    ra_terms.billing_cycle_id%type;    -- Bug 7582592

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_term_default()+');
   END IF;

       /*------------------------------------------------------+
        |  If the term has already been specified, do nothing  |
        +------------------------------------------------------*/

        IF  ( p_term_id  IS NULL )
        THEN

           /*---------------------------------------------------+
            |  First try to default the term from the customer  |
            +---------------------------------------------------*/

            IF (
                      p_customer_id   IS NOT NULL
                 AND  p_site_use_id IS NOT NULL
               )
            THEN

               IF ar_bfb_utils_pvt.get_bill_level(p_customer_id) in ('A','S') then

                  -- R12:BFB

                  select org_id
                    into l_org_id
                    from ra_cust_trx_types
                   where cust_trx_type_id = p_cust_trx_type_id;

                  l_cust_term_name := NULL;
                  l_number_of_due_dates := NULL;
                  l_term_due_date := to_date(NULL);
                  l_cust_term_id := ar_bfb_utils_pvt.get_default_term(
                           p_cust_trx_type_id,
                           p_trx_date,
                           l_org_id,
                           p_site_use_id,
                           p_customer_id);

                  if l_cust_term_id < 0 then
                     -- Error in retrieving BFB term
                     if l_cust_term_id = -91 then
                        fnd_message.set_name('AR','AR_BFB_TERM_BILL_LEVEL_NULL');
                     elsif l_cust_term_id = -92 then
                       fnd_message.set_name('AR','AR_BFB_TERM_BILL_LEVEL_WRONG');
                     elsif l_cust_term_id = -93 then
                       fnd_message.set_name('AR','AR_BFB_TERM_MISSING_AT_ACCT');
                     elsif l_cust_term_id = -94 then
                       fnd_message.set_name('AR','AR_BFB_TERM_NO_DEFAULT');
                     elsif l_cust_term_id = -95 then
                       fnd_message.set_name('AR','AR_BFB_TERM_NO_BFB_DEFAULT');
                     end if;
                     --app_exception.raise_exception;
                  else
                     begin
                        select name, billing_cycle_id
                          into l_cust_term_name, l_billing_cycle_id
                          from ra_terms
                         where term_id = l_cust_term_id;
                     exception
                     when no_data_found then
                        l_cust_term_name := null;
                     end;

                                /* Bug 7582592 */
                     IF l_billing_cycle_id is null THEN
                     l_term_due_date := arpt_sql_func_util.get_First_Due_Date(l_cust_term_id,
                                                                              p_trx_date);
                     END IF;

                  end if;

               ELSE
                  -- customer is not BFB-enabled
                BEGIN
                     SELECT tl.term_id,
                            NVL(
                                  t_su.name,
                                  NVL(
                                       t_cp1.name,
                                       t_cp2.name
                                     )
                               ),
                            arpt_sql_func_util.get_First_Due_Date( tl.term_id,
                                                                   p_trx_date),
                            count(*)
                     INTO   l_cust_term_id,
                            l_cust_term_name,
                            l_term_due_date,
                            l_number_of_due_dates
                     FROM   ra_terms              t_su,
                            ra_terms              t_cp1,
                            ra_terms              t_cp2,
                            ra_terms_lines        tl,
                            hz_customer_profiles  cp1,
                            hz_customer_profiles  cp2,
                            hz_cust_site_uses     su
                     WHERE  p_customer_id     = cp1.cust_account_id(+)
                     AND    su.site_use_id    = p_site_use_id
                     AND    cp2.cust_account_id   = p_customer_id
                     AND    su.site_use_id    = cp1.site_use_id(+)
                     AND    cp2.site_use_id   IS NULL
                     AND    su.payment_term_id = t_su.term_id(+)
                     AND    cp1.standard_terms = t_cp1.term_id(+)
                     AND    cp2.standard_terms = t_cp2.term_id(+)
                     AND    NVL(
                                  t_su.term_id,
                                  NVL(
                                       t_cp1.term_id,
                                       t_cp2.term_id
                                     )
                               )             = tl.term_id
                     AND p_trx_date BETWEEN t_su.start_date_active(+)
                                        AND NVL(t_su.end_date_active(+),
                                                p_trx_date)
                     AND p_trx_date BETWEEN t_cp1.start_date_active(+)
                                        AND NVL(t_cp1.end_date_active(+),
                                                p_trx_date)
                     AND p_trx_date BETWEEN t_cp2.start_date_active(+)
                                        AND NVL(t_cp2.end_date_active(+),
                                                p_trx_date)
                     GROUP BY  tl.term_id,
                               t_su.name,
                               t_cp1.name,
                               t_cp2.name
                               -- Guarantees cannot have split term terms
                     HAVING    1 = DECODE(p_class,
                                          'GUAR', COUNT(*),
                                                  1 );

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN NULL;
                  WHEN OTHERS THEN RAISE;
                END;
              END IF;

            END IF;

           /*----------------------------------------------------------------+
            |  If a default has been found copy the values to the out NOCOPY params |
            |  Otherwise, try to default from the transaction type.          |
            +----------------------------------------------------------------*/

            IF (l_cust_term_id  IS NOT NULL)
            THEN
                   p_default_term_id      := l_cust_term_id;
                   p_default_term_name    := l_cust_term_name;
                   p_number_of_due_dates  := l_number_of_due_dates;
                   p_term_due_date        := l_term_due_date;

            ELSIF (p_type_term_id IS NOT NULL)
               THEN

                     SELECT COUNT(*),
                            arpt_sql_func_util.get_First_Due_Date(
                                                            p_type_term_id,
                                                            p_trx_date)
                     INTO   l_number_of_due_dates,
                            l_term_due_date
                     FROM   ra_terms_lines
                     WHERE  term_id = p_type_term_id;

                     -- Guarantees cannot have split term terms

                     IF (
                                p_class = 'GUAR'
                           AND  l_number_of_due_dates > 1
                        )
                     THEN
                           p_default_term_id     := NULL;
                           p_number_of_due_dates := NULL;
                           p_number_of_due_dates := NULL;
                           p_term_due_date       := NULL;
                     ELSE
                           p_default_term_id     := p_type_term_id;
                           p_default_term_name   := p_type_term_name;
                           p_number_of_due_dates := l_number_of_due_dates;
                           p_term_due_date       := l_term_due_date;
                     END IF;
               /* Portion added for Bug 665567 : Please note that
               this portion of code is written to be executed if
               get_term_default is called from client side directly*/
            ELSIF (p_type_term_id IS  NULL)
                THEN
                     SELECT
                            rat.name,
                            rat.term_id
                     INTO   l_cust_term_name,
                            l_cust_term_id
                     FROM   ra_terms rat,
                            ra_cust_trx_types ctt
                     WHERE ctt.cust_trx_type_id=p_cust_trx_type_id
                     AND   ctt.default_term=rat.term_id(+);

                     IF (l_cust_term_id is NOT NULL)
                     THEN
                       SELECT COUNT(*),
                            arpt_sql_func_util.get_First_Due_Date(
                                                            l_cust_term_id,
                                                            p_trx_date)
                       INTO   l_number_of_due_dates,
                              l_term_due_date
                       FROM   ra_terms_lines
                       WHERE  term_id = l_cust_term_id;

                       p_default_term_id      := l_cust_term_id;
                       p_default_term_name    := l_cust_term_name;
                       p_number_of_due_dates := l_number_of_due_dates;
                       p_term_due_date       := l_term_due_date;
                     END IF;


            END IF;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_trx_defaults_3.get_term_default()-');
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_trx_defaults_3.get_term_default()');
        END IF;
        RAISE;

END get_term_default;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get_Additional_Customer_Info                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets additional information about a customer and site.                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_customer_id                                         |
 |                     p_site_use_id                                         |
 |                     p_invoice_currency_code                               |
 |                     p_previous_customer_trx_id                            |
 |                     p_ct_prev_initial_cust_trx_id                         |
 |                     p_trx_date                                            |
 |                     p_code_combination_id_gain                            |
 |              OUT:                                                         |
 |                     p_override_terms                                      |
 |                     p_commitments_exist_flag                              |
 |          IN/ OUT:                                                         |
 |                     None                                                  |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUN-96  Charlie Tomberg  Created                                   |
 |     14-NOV-97  KTANG            removed call to get_commitments_exist_flag|
 |                                                                           |
 +===========================================================================*/

PROCEDURE Get_Additional_Customer_Info(
                                       p_customer_id              IN number,
                                       p_site_use_id              IN number,
                                       p_invoice_currency_code    IN varchar2,
                                       p_previous_customer_trx_id IN number,
                                       p_ct_prev_initial_cust_trx_id IN number,
                                       p_trx_date                 IN date,
                                       p_code_combination_id_gain IN number,
                                       p_override_terms          OUT NOCOPY varchar2,
                                       p_commitments_exist_flag  OUT NOCOPY varchar2,
                                       p_agreements_exist_flag   OUT NOCOPY varchar2)
IS

   l_override_terms          hz_customer_profiles.override_terms%type;
   l_commitments_exist_flag  varchar2(1);
   l_agreements_exist_flag   varchar2(1);

BEGIN

    arp_util.debug('arp_trx_defaults_3.Get_Additional_Customer_Info()+');


    l_override_terms         :=
              arpt_sql_func_util.get_override_terms(p_customer_id,
                                                    p_site_use_id);

/* Bug 551173: Commented out NOCOPY for performance reasons

    l_commitments_exist_flag :=
              arpt_sql_func_util.get_commitments_exist_flag(
                                     p_customer_id,
                                     p_invoice_currency_code,
                                     p_previous_customer_trx_id,
                                     p_trx_date,
                                     p_ct_prev_initial_cust_trx_id,
                                     p_code_combination_id_gain,
                                     pg_base_curr_code);
*/

   l_commitments_exist_flag := 'Y';


     l_agreements_exist_flag :=
              arpt_sql_func_util.get_agreements_exist_flag(
                                     p_customer_id,
                                     p_trx_date);

     p_override_terms          := l_override_terms;
     p_commitments_exist_flag  := l_commitments_exist_flag;
     p_agreements_exist_flag   := l_agreements_exist_flag;

     arp_util.debug('p_customer_id                 = ' ||
                    TO_CHAR(p_customer_id));
     arp_util.debug('p_site_use_id                 = ' ||
                    TO_CHAR(p_site_use_id));
     arp_util.debug('p_invoice_currency_code       = ' ||
                    p_invoice_currency_code);
     arp_util.debug('p_previous_customer_trx_id    = ' ||
                    TO_CHAR(p_previous_customer_trx_id));
     arp_util.debug('p_ct_prev_initial_cust_trx_id = ' ||
                    TO_CHAR(p_ct_prev_initial_cust_trx_id));
     arp_util.debug('p_trx_date                    = ' ||
                    TO_CHAR(p_trx_date));
     arp_util.debug('p_code_combination_id_gain    = ' ||
                    TO_CHAR(p_code_combination_id_gain));

     arp_util.debug('p_override_terms              = ' || l_override_terms);
     arp_util.debug('p_commitments_exist_flag      = ' ||
                    l_commitments_exist_flag);
     arp_util.debug('p_agreements_exist_flag       = ' ||
                    l_agreements_exist_flag);

     arp_util.debug('arp_trx_defaults_3.Get_Additional_Customer_Info()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : '||
                   'arp_trx_defaults_3.Get_Additional_Customer_Info()-');

    RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get_Payment_Channel_name                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Get payment channel name based on payment channel code.                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_payment_channel_code                                |
 |              OUT:                                                         |
 |                     NONE                                                  |
 |                                                                           |
 | RETURNS    : payment_channel_name if exists                               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-Aug-05  Surendra Rajan   Created                                   |
 |                                                                           |
 +===========================================================================*/

FUNCTION  get_payment_channel_name(
                                      p_payment_channel_code      IN
                                        ar_receipt_methods.payment_channel_code%type
                              ) RETURN VARCHAR2 IS

l_payment_channel_name iby_fndcpt_all_pmt_channels_v.payment_channel_name%type; --corrected the field name Bug5367658
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_trx_defaults_3.get_payment_channel_name()+');
  END IF;

          Select payment_channel_name
            into l_payment_channel_name
          from   iby_fndcpt_all_pmt_channels_v  pmt_cv
          where pmt_cv.instrument_type not in ('MANUAL', 'PINLESSDEBITCARD')
           and  pmt_cv.payment_channel_code = p_payment_channel_code;

  RETURN l_payment_channel_name ;
EXCEPTION
    WHEN NO_DATA_FOUND
         THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('get_payment_channel_name: ' || ' NOT FOUND ');
               END IF;
               RETURN(NULL);

    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_payment_channel_name: ' ||
                'EXCEPTION:  arp_trx_defaults_3.get_payment_channel_name()');
         arp_util.debug('get_payment_channel_name: ' || '------- parameters for get_payment_channel_name----');
         arp_util.debug('get_payment_channel_name: ' || 'p_payment_channel_code = ' || p_payment_channel_code);
      END IF;

      RAISE;

END get_payment_channel_name;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get_Party_id                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Get party id based on the customer account id.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_cust_account_id                                     |
 |              OUT:                                                         |
 |                     NONE                                                  |
 |                                                                           |
 | RETURNS    : party_id if exists                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-Aug-05  Surendra Rajan   Created                                   |
 |                                                                           |
 +===========================================================================*/

FUNCTION  get_party_id (
                                     p_cust_account_id           IN
                                       hz_cust_accounts.cust_account_id%type
                       ) RETURN NUMBER IS
l_party_id number;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_trx_defaults_3.get_party_id()+');
  END IF;

          Select party_id
            into l_party_id
          from  hz_cust_accounts
          where cust_account_id = p_cust_account_id ;
  RETURN l_party_id;
EXCEPTION
    WHEN NO_DATA_FOUND
         THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('get_party_id: ' || ' NOT FOUND ');
               END IF;
               RETURN(NULL);

    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_party_id : ' ||
                'EXCEPTION:  arp_trx_defaults_3.get_party_id()');
         arp_util.debug('get_party_id: ' || '------- parameters for get_party_id ----');
         arp_util.debug('get_party_id: ' || 'p_cust_account_id = ' || p_cust_account_id);
      END IF;

      RAISE;

END get_party_id;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get_payment_instrument                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets instrument information from oracle payments based on the payment  |
 |    channel code and the payment trxn extension id.                        |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_payment_trxn_extension_id                           |
 |              OUT:                                                         |
 |                     NONE                                                  |
 |                                                                           |
 | RETURNS    : Instrument number if exists                                  |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-Aug-05  Surendra Rajan   Created                                   |
 |     04-AUG-06  Gyanajyothi      Modified to include Bills receivable      |
 |                                 Bug 5435941                                          |
 +===========================================================================*/

FUNCTION  get_payment_instrument(
                                      p_payment_trxn_extension_id      IN
                                        ra_customer_trx.payment_trxn_extension_id%type,
                                      p_payment_channel_code      IN
                                        ar_receipt_methods.payment_channel_code%type
                               ) RETURN VARCHAR2 IS
l_instrument       iby_trxn_extensions_v.card_number%type;
l_instrument_type  iby_trxn_extensions_v.instrument_type%type;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_trx_defaults_3.get_payment_instrument()+');
  END IF;

--Bug 8278615.
  SELECT instrument_type
  INTO l_instrument_type
  FROM iby_fndcpt_pmt_chnnls_b
  WHERE payment_channel_code = p_payment_channel_code
  AND instrument_type in ('CREDITCARD', 'BANKACCOUNT');

  IF PG_DEBUG in ('Y', 'C') THEN
	arp_util.debug('p_payment_trxn_extension_id: ' || p_payment_trxn_extension_id);
        arp_util.debug('l_instrument_type: ' || l_instrument_type);
  END IF;

	SELECT decode (nvl(u.instrument_type, p.instrument_type)
              , 'BANKACCOUNT', b.masked_bank_account_num
              , 'CREDITCARD',  c.masked_cc_number
              , NULL) instrument
	into l_instrument
	FROM
	  iby_creditcard c,
	  iby_ext_bank_accounts b,
	  iby_fndcpt_pmt_chnnls_b p,
	  iby_fndcpt_pmt_chnnls_tl pt,
	  iby_fndcpt_tx_extensions x,
	  iby_pmt_instr_uses_all u,
	  fnd_application a
	 WHERE (x.instr_assignment_id = u.instrument_payment_use_id(+))
	 AND (DECODE(u.instrument_type, 'CREDITCARD',u.instrument_id, NULL) = c.instrid(+))
	 AND (DECODE(u.instrument_type, 'BANKACCOUNT',u.instrument_id, NULL) = b.ext_bank_account_id(+))
	 AND (x.payment_channel_code  = p.payment_channel_code)
	 AND (x.origin_application_id = a.application_id)
	 AND (P.payment_channel_code  = pt.payment_channel_code)
	 AND (PT.LANGUAGE = USERENV('LANG'))
	 AND trxn_extension_id = p_payment_trxn_extension_id
	 AND nvl(u.instrument_type, p.instrument_type) = l_instrument_type;

  IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('l_instrument: ' || l_instrument);
  END IF;

  RETURN l_instrument;
EXCEPTION
    WHEN NO_DATA_FOUND
         THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('get_payment_instrument: ' || ' NOT FOUND ');
               END IF;
               RETURN(NULL);

    WHEN TOO_MANY_ROWS
         THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_util.debug('get_payment_instrument: ' || 'TWO MANY ROWS FOUND ');
               END IF;
               RAISE;

    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_payment_instrument: ' ||
                'EXCEPTION:  arp_trx_defaults_3.get_payment_instrument() '|| sqlerrm);
         arp_util.debug('get_payment_instrument: ' || '------- parameters ----');
         arp_util.debug('get_payment_instrument: ' || 'p_payment_channel_code= ' ||
                                                   p_payment_channel_code);
         arp_util.debug('get_payment_instrument: ' || 'p_payment_trxn_extension_id= ' ||
                                                   p_payment_trxn_extension_id);
      END IF;

      RAISE;
END get_payment_instrument;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get_BR_Bank_Defaults                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets BR Bank information from oracle payments based on the payment     |
 |    channel code and the payment trxn extension id.                        |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                     p_payment_trxn_extension_id                           |
 |              OUT: p_bank_name,p_branch_name,p_instr_assign_id             |
 |                   p_instr_number		                             |
 |                                                                           |
 | RETURNS    : Instrument details if exists                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-Feb-06  Gyanajyothi G    Created : Bug 4778839                     |
 |                                                                           |
 +===========================================================================*/


PROCEDURE get_br_bank_defaults(    p_payment_trxn_extension_id      IN
                                        ra_customer_trx.payment_trxn_extension_id%type,
                                   p_payment_channel_code      IN
                                        ar_receipt_methods.payment_channel_code%type,
                                   p_bank_name OUT NOCOPY
                                         iby_trxn_extensions_v.bank_name%type,
                                   p_branch_name OUT NOCOPY
                                         iby_trxn_extensions_v.bank_branch_name%type,
                                   p_instr_assign_id OUT NOCOPY
                                          iby_trxn_extensions_v.instr_assignment_id%type,
                                   p_instr_number OUT NOCOPY
                                          iby_trxn_extensions_v.account_number%type)
IS

BEGIN
select bank_name,bank_branch_name,instr_assignment_id,account_number
into  p_bank_name,p_branch_name,p_instr_assign_id,p_instr_number
from iby_trxn_extensions_v
where trxn_extension_id = p_payment_trxn_extension_id
and payment_channel_code = p_payment_channel_code;

exception
when no_data_found then
arp_util.debug('ar_br_bank_defaults - No data found');
when others then
arp_util.debug('ar_br_bank_defaults - Others');
End;


--Bug 5507178 To Default the Instrument Details for a transaction

PROCEDURE get_instr_defaults(p_org_id IN  ra_customer_trx.org_id%type,
			     p_paying_customer_id  IN  ra_customer_trx.paying_customer_id%type,
                             p_paying_site_use_id IN iby_fndcpt_payer_assgn_instr_v.acct_site_use_id%type,
                             p_instrument_type IN iby_fndcpt_payer_assgn_instr_v.instrument_type%type,
                             p_currency_code IN    iby_fndcpt_payer_assgn_instr_v.currency_code%type             ,
                             p_instrument_assignment_id OUT NOCOPY iby_trxn_extensions_v.instr_assignment_id%type

			   )
IS
l_instr_assignments    IBY_FNDCPT_SETUP_PUB.pmtinstrassignment_tbl_type;
l_payer                IBY_FNDCPT_COMMON_PUB.payercontext_rec_type;
l_payer_equivalency    VARCHAR2(500);
l_conditions           IBY_FNDCPT_COMMON_PUB.trxncontext_rec_type;
l_result_limit         IBY_FNDCPT_COMMON_PUB.resultlimit_rec_type;


l_response             IBY_FNDCPT_COMMON_PUB.result_rec_type;
l_return_status        VARCHAR2(4000);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(4000);

  -- This values based on global variables from FND_API G_TRUE and G_FALSE;
  l_true                 VARCHAR2(1) := 'T';
  l_false                VARCHAR2(1) := 'F';


BEGIN
      l_payer.payment_function                  := 'CUSTOMER_PAYMENT';
      l_payer.party_id                          := arp_trx_defaults_3.get_party_Id(p_paying_customer_id);
      l_payer.org_type                          := 'OPERATING_UNIT';
      l_payer.org_id                            := p_org_id;
      l_payer.cust_account_id                   := p_paying_customer_id;
      l_payer.account_site_id                   := p_paying_site_use_id;

      l_payer_equivalency                       := 'UPWARD';--Verify this

      l_conditions.application_id               := 222;
--      l_conditions.transaction_type           := p_instrument_type ; --:IBY_TRXN_PARAMS.transaction_type;
      l_conditions.Payment_InstrType 		:= p_instrument_type ;
      l_conditions.org_type                     := 'OPERATING_UNIT';
      l_conditions.org_id                       := p_org_id;
      l_conditions.currency_code                := p_currency_code;
      l_conditions.payment_amount               := null ; --:IBY_TRXN_PARAMS.payment_amount;

	 -- return only the default payment instrument based on the priority
      l_result_limit.default_flag := 'Y';


  -- Call funds capture PL/SQL API to query applicable payment instrument assignments
  IBY_FNDCPT_SETUP_PUB.get_trxn_appl_instr_assign(
      p_api_version           => 1.0,
      p_init_msg_list         => l_false,
      x_return_status         => l_return_status,
      x_msg_count             => l_msg_count,
      x_msg_data              => l_msg_data,
      p_payer                 => l_payer,
      p_payer_equivalency     => l_payer_equivalency,
      p_conditions            => l_conditions,
      p_result_limit          => l_result_limit,
      x_assignments           => l_instr_assignments,
      x_response              => l_response);


   IF (l_return_status <> 'S') THEN
	arp_util.debug('Unable to default the Instrument Details');

   ELSE
/*Bug6135223*/
     If l_instr_assignments.count = 0 Then
       p_instrument_assignment_id := Null;
     Else
       p_instrument_assignment_id :=  l_instr_assignments(l_instr_assignments.FIRST).assignment_id;
     End If;
  END IF;

END;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/
PROCEDURE init IS
BEGIN

  pg_text_dummy   := arp_ct_pkg.get_text_dummy;
  pg_flag_dummy   := arp_ct_pkg.get_flag_dummy;
  pg_number_dummy := arp_ct_pkg.get_number_dummy;
  pg_date_dummy   := arp_ct_pkg.get_date_dummy;

  pg_base_curr_code    := arp_global.functional_currency;
  pg_base_precision    := arp_global.base_precision;
  pg_base_min_acc_unit := arp_global.base_min_acc_unit;
  pg_set_of_books_id   :=
          arp_trx_global.system_info.system_parameters.set_of_books_id;
END init;

BEGIN
   init;
END ARP_TRX_DEFAULTS_3;

/
