--------------------------------------------------------
--  DDL for Package Body ARP_TRX_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_LINE_UTIL" AS
/* $Header: ARTCTLTB.pls 120.12.12010000.3 2008/11/21 09:37:10 npanchak ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |    derive_last_date_to_cr                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the Last Period to Credit as a date              |
 |    given the last period number and customer_trx_line_id and for an       |
 |    invoice line with rules.                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_customer_trx_line_id                                     |
 |                p_last_period_to_cr                                        |
 |                p_period_set_name                                          |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-MAR-96  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION derive_last_date_to_cr(
              p_customer_trx_line_id IN number,
              p_last_period_to_cr    IN number,
              p_period_set_name      IN varchar2 DEFAULT NULL) RETURN date IS

  l_count            number;
  l_last_gl_date     date;
  l_period_set_name  varchar2(15);

BEGIN

  /*---------------------------------------------+
   |  If period set name was not passed, get it  |
   +---------------------------------------------*/

  IF ( p_period_set_name IS NULL )
    THEN
      SELECT sb.period_set_name
        INTO l_period_set_name
        FROM ar_system_parameters sp,
             gl_sets_of_books sb
       WHERE sp.set_of_books_id = sb.set_of_books_id;
    ELSE
      l_period_set_name := p_period_set_name;
  END IF;

  SELECT MAX(gl_date),
         count(*)
    INTO l_last_gl_date,
         l_count
    FROM ar_revenue_assignments
   WHERE customer_trx_line_id = p_customer_trx_line_id
     AND account_class        = 'REV'
     AND period_set_name      = l_period_set_name
     AND rownum <= DECODE(p_last_period_to_cr -
                                   round(p_last_period_to_cr, 0),
                          0, p_last_period_to_cr,
                             p_last_period_to_cr + 1 );

  IF ( p_last_period_to_cr -  trunc(p_last_period_to_cr, 0) <> 0 )
    THEN
      /*-------------------------------------------------------------------+
       |  Last Date =                                                      |
       |    (days in period * fractional part of last period to cr) +      |
       |    last full period                                               |
       +-------------------------------------------------------------------*/

      SELECT ( (l_last_gl_date - max(gl_date) ) *
               (p_last_period_to_cr - trunc(p_last_period_to_cr, 0) )
             ) + max(gl_date)
        INTO l_last_gl_date
        FROM ar_revenue_assignments
       WHERE customer_trx_line_id = p_customer_trx_line_id
         AND account_class        = 'REV'
         AND period_set_name      = l_period_set_name
         AND rownum <= l_count - 1;
  END IF;

  RETURN( l_last_gl_date );

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END derive_last_date_to_cr;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    derive_last_pd_to_cr                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the Last Period to Credit as a real number       |
 |    given the last credit date and customer_trx_line_id for an             |
 |    invoice line with rules.                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_customer_trx_line_id                                     |
 |                p_last_date_to_credit                                      |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-MAR-96  Martin Johnson      Created                                |
 |     21-MAR-96  Martin Johnson      Added tokens to message                |
 |                                      AR_TW_LAST_GL_DATE                   |
 |                                                                           |
 +===========================================================================*/

FUNCTION derive_last_pd_to_cr( p_customer_trx_line_id IN number,
                               p_last_date_to_credit  IN date ) RETURN number
IS

  l_min_gl_date     date;
  l_max_gl_date     date;

  l_period_count    number;
  l_period_fraction number;
  l_prior_date      date;

  CURSOR gl_dates IS
    SELECT gl_date
      FROM ra_customer_trx_lines l,
           ar_revenue_assignments ra
     WHERE l.customer_trx_line_id = p_customer_trx_line_id
       AND l.customer_trx_line_id = ra.customer_trx_line_id
       AND ra.account_class = 'REV'
  ORDER BY gl_date;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_line_util.derive_last_pd_to_cr()+');
  END IF;

  /*-------------------------------------------------+
   |  Validate that the Last GL Date is between the  |
   |  first and last invoice GL Date                 |
   +-------------------------------------------------*/

  SELECT MIN(gl_date),
         MAX(gl_date)
    INTO l_min_gl_date,
         l_max_gl_date
    FROM ra_customer_trx_lines l,
         ar_revenue_assignments ra
   WHERE l.customer_trx_line_id = p_customer_trx_line_id
     AND l.customer_trx_line_id = ra.customer_trx_line_id
     AND ra.account_class = 'REV';

  IF ( p_last_date_to_credit BETWEEN l_min_gl_date
                                 AND l_max_gl_date )
    THEN null;
    ELSE
      fnd_message.set_name('AR', 'AR_TW_LAST_GL_DATE');
      fnd_message.set_token('MIN_DATE', TO_CHAR(l_min_gl_date, 'DD-MON-YYYY'));
      fnd_message.set_token('MAX_DATE', TO_CHAR(l_max_gl_date, 'DD-MON-YYYY'));
      app_exception.raise_exception;
  END IF;

  l_period_count := 0;

  FOR gl_dates_rec IN gl_dates LOOP

    l_period_count := l_period_count + 1;

    /*-----------------------------------------------------+
     |  If p_last_date_to_credit <= fetched gl_date        |
     |  THEN compute the last period to credit and return  |
     |  ELSE set the prior date to the fetched date and    |
     |       continue looping.                             |
     +-----------------------------------------------------*/

    IF ( p_last_date_to_credit <= gl_dates_rec.gl_date )
      THEN

        /*------------------------------------------------------------+
         |  If p_last_date_to_credit < fetched gl_date                |
         |  THEN decrement the period count by one since we have      |
         |       gone too far, and compute the last period to credit  |
         |       including the fractional part                        |
         |  ELSE set the last period to credit to the current count   |
         +------------------------------------------------------------*/

        IF ( p_last_date_to_credit < gl_dates_rec.gl_date )
          THEN

            l_period_count := l_period_count - 1;

            /*----------------------------------------------+
             |  If the current date = the prior date        |
             |  THEN set the period fraction to 0           |
             |  ELSE set the period fraction to             |
             |       (days into period) / (period length)   |
             +----------------------------------------------*/

            IF ( gl_dates_rec.gl_date = l_prior_date )
              THEN
                l_period_fraction := 0;

              ELSE
                l_period_fraction := ( p_last_date_to_credit - l_prior_date ) /
                                     ( gl_dates_rec.gl_date - l_prior_date );
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('arp_trx_line_util.derive_last_pd_to_cr()-');
            END IF;
            RETURN( l_period_count + l_period_fraction );

          ELSE /* p_last_date_to_credit = gl_dates_rec.gl_date */

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('arp_trx_line_util.derive_last_pd_to_cr()-');
            END IF;
            RETURN( l_period_count );

        END IF;  /* IF ( p_last_date_to_credit < gl_dates_rec.gl_date ) */

     ELSE  /* p_last_date_to_credit > gl_dates_rec.gl_date */

       l_prior_date := gl_dates_rec.gl_date;

    END IF;  /* IF ( p_last_date_to_credit <= gl_dates_rec.gl_date ) */

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_trx_line_util.derive_last_pd_to_cr()');
       arp_util.debug('derive_last_pd_to_cr: ' || '----- Parameters for ' ||
                   'arp_trx_line_util.derive_last_pd_to_cr() ' || '-----' );
       arp_util.debug('derive_last_pd_to_cr: ' || 'p_customer_trx_line_id = ' || p_customer_trx_line_id );
       arp_util.debug('derive_last_pd_to_cr: ' || 'p_last_date_to_credit  = ' || p_last_date_to_credit );
    END IF;
    RAISE;

END derive_last_pd_to_cr;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_default_line_num                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the default line number.                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_id                                    |
 |              OUT:                                                         |
 |              	p_line_number                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-DEC-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_default_line_num(p_customer_trx_id IN   number,
                               p_line_number     OUT NOCOPY  number )
IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_line_util.get_default_line_num()+');
  END IF;

  SELECT nvl( max(line_number), 0 ) + 1
    INTO p_line_number
    FROM ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
     AND line_type in ('LINE', 'CB', 'CHARGES');

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_line_util.get_default_line_num()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_trx_line_util.get_default_line_num()');
       arp_util.debug('get_default_line_num: ' ||
                '---------- ' ||
                'Parameters for arp_trx_line_util.get_default_line_num() ' ||
                '---------- ');
       arp_util.debug('get_default_line_num: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
    END IF;

    RAISE;

END get_default_line_num;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_item_flex_defaults                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the defaults for the specified item flex                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_inventory_item_id                                    |
 |                    p_organization_id                                      |
 |                    p_trx_date                                             |
 |                    p_invoicing_rule_id                                    |
 |              OUT:                                                         |
 |                    p_description                                          |
 |                    p_primary_uom_code                                     |
 |                    p_primary_uom_name                                     |
 |                    p_accounting_rule_id                                   |
 |                    p_accounting_rule_name                                 |
 |                    p_accounting_rule_duration                             |
 |                    p_accounting_rule_type                                 |
 |                    p_rule_start_date                                      |
 |                    p_frequency                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-DEC-95  Martin Johnson      Created                                |
 |     05-FEB-96  Martin Johnson      Added parameter p_frequency            |
 |     18-MAR-96  Martin Johnson      Validate uom against mtl_item_uoms_view|
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_item_flex_defaults(p_inventory_item_id IN Number,
                                 p_organization_id IN Number,
                                 p_trx_date IN Date,
                                 p_invoicing_rule_id IN Number,
                                 p_description OUT NOCOPY varchar2,
                                 p_primary_uom_code OUT NOCOPY varchar2,
                                 p_primary_uom_name OUT NOCOPY varchar2,
                                 p_accounting_rule_id OUT NOCOPY Number,
                                 p_accounting_rule_name OUT NOCOPY Varchar2,
                                 p_accounting_rule_duration OUT NOCOPY number,
                                 p_accounting_rule_type OUT NOCOPY varchar2,
                                 p_rule_start_date OUT NOCOPY
                                   date,
                                 p_frequency OUT NOCOPY varchar2
                                   )
IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_line_util.get_item_flex_defaults()+');
  END IF;

    SELECT msi.description,
           muom.uom_code,
           muom.unit_of_measure_tl,          /*4762000*/
           DECODE( rr.status,
                     'A', msi.accounting_rule_id,
                          null ),
           DECODE( rr.status,
                     'A', rr.name,
                          null ),
           DECODE( rr.status,
                     'A', DECODE(rr.type,
                                   'ACC_DUR', 1,
                                   'A',       rr.occurrences )
                 ),
           DECODE( rr.status,
                     'A', rr.type,
                          null ),
           DECODE( rr.status,
                     'A', DECODE( rr.frequency,
                                    'SPECIFIC', min(rs.rule_date),
                                      DECODE( p_invoicing_rule_id,
                                              -2, p_trx_date,
                                              -3, sysdate )
                                ),
                     null
                 ),
           DECODE( rr.status,
                     'A', rr.frequency,
                     null )
      INTO p_description,
           p_primary_uom_code,
           p_primary_uom_name,
           p_accounting_rule_id,
           p_accounting_rule_name,
           p_accounting_rule_duration,
           p_accounting_rule_type,
           p_rule_start_date,
           p_frequency
      FROM mtl_system_items msi,
           mtl_item_uoms_view muom,
           ra_rules rr,
           ra_rule_schedules rs
     WHERE msi.inventory_item_id     = p_inventory_item_id
       AND msi.organization_id       = p_organization_id
       AND msi.primary_uom_code      = muom.uom_code (+)
       AND muom.inventory_item_id(+) = p_inventory_item_id
       AND muom.organization_id(+)   = p_organization_id
       AND msi.accounting_rule_id    = rr.rule_id (+)
       AND rr.rule_id                = rs.rule_id (+)
  GROUP BY msi.description,
           muom.uom_code,
           muom.unit_of_measure_tl,          /*4762000*/
           rr.status,
           msi.accounting_rule_id,
           rr.name,
           rr.type,
           rr.occurrences,
           rr.frequency;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_line_util.get_item_flex_defaults()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: arp_trx_line_util.get_item_flex_defaults()');
       arp_util.debug('get_item_flex_defaults: ' ||
             '---------- ' ||
             'Parameters for arp_trx_line_util.get_item_flex_defaults() ' ||
             '---------- ');
       arp_util.debug('get_item_flex_defaults: ' || 'p_inventory_item_id = ' || p_inventory_item_id);
       arp_util.debug('get_item_flex_defaults: ' || 'p_organization_id = ' || p_organization_id );
       arp_util.debug('get_item_flex_defaults: ' || 'p_trx_date = ' || p_trx_date );
       arp_util.debug('get_item_flex_defaults: ' || 'p_invoicing_rule_id = ' || p_invoicing_rule_id );
    END IF;

  RAISE;

END get_item_flex_defaults;

PROCEDURE get_max_line_number(p_customer_trx_id IN   number, p_line_number OUT NOCOPY  NUMBER ) IS
 l_line_number   NUMBER;

 BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('arp_trx_util_line.get_max_line_number(+)');
     END IF;

     ---
     --- Get Maximum Line Number
     ---
         SELECT
                nvl(max(line_number) , 0)
         INTO
                l_line_number
         FROM   ra_customer_trx_lines
         WHERE  customer_trx_id = p_customer_trx_id
                AND line_type IN ('LINE','CB','CHARGES');
     p_line_number := l_line_number+1;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('arp_trx_util_line.get_max_line_number(-)');
     END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION:arp_trx_util_line.get_max_line_number');
      END IF;
      RAISE;
End get_max_line_number;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_oe_header_id                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the oe_header_id for the given oe_line_id                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_oe_line_id                                           |
 |                    p_interface_context                                    |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     23-MAY-02  Ramakant Alat       Created                                |
 |     05-DEC-02  M Raymond    Bug 2676869   Added logic to the exception
 |                                           handler to mask invalid number
 |                                           errors.  These occur if the
 |                                           line transaction flexfield
 |                                           has non-numeric data in specific
 |                                           segments.                      |
 |     05-DEC-02                             Also added support for
 |                                           ORDER MANAGEMENT context.
 +===========================================================================*/
FUNCTION get_oe_header_id(p_oe_line_id IN  varchar2, p_interface_context IN  VARCHAR2 ) RETURN NUMBER IS

 l_oe_header_id   NUMBER := null;

 BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('arp_trx_util_line.get_oe_header_id(+)');
     END IF;

     ---
     --- Get OE Header Id
     ---
	 IF p_interface_context in ('ORDER ENTRY','ORDER MANAGEMENT') THEN
         SELECT
                header_id
         INTO
                l_oe_header_id
         FROM   oe_order_lines
         WHERE  line_id = to_number(p_oe_line_id)
         and rownum < 2;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('arp_trx_util_line.get_oe_header_id(-)');
     END IF;

	 RETURN l_oe_header_id;

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      l_oe_header_id := NULL;
      RETURN l_oe_header_id;
   WHEN INVALID_NUMBER
   THEN
      l_oe_header_id := NULL;
      RETURN l_oe_header_id;
   WHEN OTHERS
   THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('EXCEPTION:arp_trx_util_line.get_oe_header_id ');
         arp_util.debug('get_oe_header_id: ' || SQLERRM(SQLCODE));
      END IF;
      RAISE;
End get_oe_header_id;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_tax_classification_code                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    When transactions are upgraded from 11i to R12,                        |
 |    tax classification code is not populated even though                   |
 |    vat_tax_id is NOT NULL. In that case this function returns             |
 |    the Tax Classification Code as varchar2                                |
 |    given the vat_tax_id number for an Invoice Line.                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_vat_tax_id                                               |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     13-MAR-07    Nanda Kishore     Created                                |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_tax_classification_code(p_vat_tax_id IN Number) RETURN VARCHAR2
IS
 l_tax_classification_code VARCHAR2(50);
BEGIN
 SELECT
     zx.tax_classification_code
   INTO
     l_tax_classification_code
   FROM
     zx_id_tcc_mapping zx
   WHERE
     zx.source = 'AR' and
     zx.tax_rate_code_id = p_vat_tax_id;

 Return l_tax_classification_code;
EXCEPTION
   WHEN OTHERS THEN
     Return NULL;
End get_tax_classification_code;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_tax_amount		                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |	AR_DOCS_RECEIVABLES_V view is modifed to show tax amount.	     |
 |      The TAX amount is calculated in this function depending upon	     |
 |	the value of tax_type passed [ VAT or SALES_TAX ]		     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_customer_trx_id                                          |
 |                p_tax_type	                                             |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     20-MAY-08    Sachin Dixit     Created                                |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_tax_amount( p_customer_trx_id IN NUMBER,
			 p_tax_type IN VARCHAR2) RETURN NUMBER
IS
   tax_amount	NUMBER ;
BEGIN
   IF p_tax_type = 'VAT'
   THEN
	SELECT sum(zl.tax_amt) INTO tax_amount
	FROM ra_customer_trx_lines_all trxl, zx_lines zl
	WHERE trxl.line_type = 'TAX'
	  AND trxl.tax_line_id = zl.tax_line_id
	  AND zl.tax_type_code like 'VAT%'
	  AND zl.application_id = 222
	  AND zl.entity_code = 'TRANSACTIONS'
	  AND trxl.customer_trx_id = p_customer_trx_id;
   ELSE
	SELECT sum(zl.tax_amt) INTO tax_amount
	FROM   ra_customer_trx_lines_all trxl, zx_lines zl
	WHERE  trxl.line_type = 'TAX'
	  AND  trxl.tax_line_id = zl.tax_line_id
	  AND  (zl.tax_type_code is null OR zl.tax_type_code not like 'VAT%')
	  AND  zl.application_id = 222
	  AND  zl.entity_code = 'TRANSACTIONS'
	  AND  trxl.customer_trx_id = p_customer_trx_id;
   END IF;

RETURN tax_amount;
EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_tax_amount		                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |	AR_DOCUMENT_LINES_V view is modifed to show tax amount.	             |
 |      The TAX amount is calculated in this function depending upon	     |
 |	the value of tax_type passed [ VAT or SALES_TAX ]		     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_customer_trx_id                                          |
 |                p_customer_trx_line_id                                     |
 |                p_tax_type	                                             |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-NOV-08    Nanda Emani       Created                                |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_tax_amount( p_customer_trx_id IN NUMBER,
                         p_customer_trx_line_id IN NUMBER,
			 p_tax_type IN VARCHAR2) RETURN NUMBER
IS
   tax_amount	NUMBER ;
BEGIN
   IF p_tax_type = 'VAT'
   THEN
	SELECT sum(zl.tax_amt) INTO tax_amount
	FROM ra_customer_trx_lines trxl, zx_lines zl
	WHERE trxl.line_type = 'TAX'
	  AND trxl.tax_line_id = zl.tax_line_id
	  AND zl.tax_type_code like 'VAT%'
	  AND zl.application_id = 222
	  AND zl.entity_code = 'TRANSACTIONS'
	  AND trxl.customer_trx_id = p_customer_trx_id
          AND trxl.link_to_cust_trx_line_id = p_customer_trx_line_id;
   ELSE
	SELECT sum(zl.tax_amt) INTO tax_amount
	FROM   ra_customer_trx_lines trxl, zx_lines zl
	WHERE  trxl.line_type = 'TAX'
	  AND  trxl.tax_line_id = zl.tax_line_id
	  AND  (zl.tax_type_code is null OR zl.tax_type_code not like 'VAT%')
	  AND  zl.application_id = 222
	  AND  zl.entity_code = 'TRANSACTIONS'
	  AND  trxl.customer_trx_id = p_customer_trx_id
          AND  trxl.link_to_cust_trx_line_id = p_customer_trx_line_id;
   END IF;

RETURN tax_amount;
EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END;

END ARP_TRX_LINE_UTIL;

/
