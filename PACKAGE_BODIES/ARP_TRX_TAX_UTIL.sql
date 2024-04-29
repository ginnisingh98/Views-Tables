--------------------------------------------------------
--  DDL for Package Body ARP_TRX_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_TAX_UTIL" AS
/* $Header: ARTCTTXB.pls 115.4 2003/10/10 14:27:45 mraymond ship $ */

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
 |     03-JAN-96  Sunil Mody          Created                                |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE get_default_line_num(p_customer_trx_id IN
                                 ra_customer_trx_lines.customer_trx_id%type,
                               p_customer_trx_line_id IN
                                ra_customer_trx_lines.customer_trx_line_id%type,
                               p_line_number     OUT NOCOPY
                                 ra_customer_trx_lines.line_number%type )
IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_tax_util.get_default_line_num()+');
  END IF;

  SELECT nvl( max(line_number), 0 ) + 1
    INTO p_line_number
    FROM ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
     AND link_to_cust_trx_line_id = p_customer_trx_line_id
     AND line_type = 'TAX';

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_tax_util.get_default_line_num()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_trx_tax_util.get_default_line_num()');
       arp_util.debug('get_default_line_num: ' ||
                '---------- ' ||
                'Parameters for arp_trx_tax_util.get_default_line_num() ' ||
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
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-JAN-96  Sunil Mody          Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_item_flex_defaults(p_inventory_item_id IN
                                   mtl_system_items.inventory_item_id%type,
                                 p_organization_id IN
                                   mtl_system_items.organization_id%type,
                                 p_trx_date IN
                                   ra_customer_trx.trx_date%type,
                                 p_invoicing_rule_id IN
                                   ra_customer_trx.invoicing_rule_id%type,
                                 p_description OUT NOCOPY
                                   mtl_system_items.description%type,
                                 p_primary_uom_code OUT NOCOPY
                                   mtl_system_items.primary_uom_code%type,
                                 p_primary_uom_name OUT NOCOPY
                                   mtl_units_of_measure.unit_of_measure%type,
                                 p_accounting_rule_id OUT NOCOPY
                                   mtl_system_items.accounting_rule_id%type,
                                 p_accounting_rule_name OUT NOCOPY
                                   ra_rules.name%type,
                                 p_accounting_rule_duration OUT NOCOPY
                                   ra_rules.occurrences%type,
                                 p_accounting_rule_type OUT NOCOPY
                                   ra_rules.type%type,
                                 p_rule_start_date OUT NOCOPY
                                   date )
IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_tax_util.get_item_flex_defaults()+');
  END IF;

    SELECT msi.description,
           DECODE( SIGN( p_trx_date - TRUNC( NVL(muom.disable_date,
                                                 p_trx_date) ) ),
                     -1, muom.uom_code,
                      0, muom.uom_code,
                      1, null
                 ),
           DECODE( SIGN( p_trx_date - TRUNC( NVL(muom.disable_date,
                                                 p_trx_date) ) ),
                     -1, muom.unit_of_measure,
                      0, muom.unit_of_measure,
                      1, null
                 ),
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
                 )
      INTO p_description,
           p_primary_uom_code,
           p_primary_uom_name,
           p_accounting_rule_id,
           p_accounting_rule_name,
           p_accounting_rule_duration,
           p_accounting_rule_type,
           p_rule_start_date
      FROM mtl_system_items msi,
           mtl_units_of_measure muom,
           ra_rules rr,
           ra_rule_schedules rs
     WHERE msi.inventory_item_id  = p_inventory_item_id
       AND msi.organization_id    = p_organization_id
       AND msi.primary_uom_code   = muom.uom_code (+)
       AND msi.accounting_rule_id = rr.rule_id (+)
       AND rr.rule_id             = rs.rule_id (+)
  GROUP BY msi.description,
           muom.disable_date,
           muom.uom_code,
           muom.unit_of_measure,
           rr.status,
           msi.accounting_rule_id,
           rr.name,
           rr.type,
           rr.occurrences,
           rr.frequency;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_tax_util.get_item_flex_defaults()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION: arp_trx_tax_util.get_item_flex_defaults()');
       arp_util.debug('get_item_flex_defaults: ' ||
             '---------- ' ||
             'Parameters for arp_trx_tax_util.get_item_flex_defaults() ' ||
             '---------- ');
       arp_util.debug('get_item_flex_defaults: ' || 'p_inventory_item_id = ' || p_inventory_item_id);
       arp_util.debug('get_item_flex_defaults: ' || 'p_organization_id = ' || p_organization_id );
       arp_util.debug('get_item_flex_defaults: ' || 'p_trx_date = ' || p_trx_date );
       arp_util.debug('get_item_flex_defaults: ' || 'p_invoicing_rule_id = ' || p_invoicing_rule_id );
    END IF;

  RAISE;

END get_item_flex_defaults;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_summary                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the sum of the extended amount.                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_id                                    |
 |              OUT:                                                         |
 |              	p_total                                              |
 |              	p_total_rtot_db                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-JAN-96  Sunil Mody          Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE select_summary(p_customer_trx_id IN
                           ra_customer_trx_lines.customer_trx_id%type,
                         p_customer_trx_line_id IN number,
                         p_mode                 IN varchar2,
                         p_total           IN OUT NOCOPY
                           ra_customer_trx_lines.extended_amount%type,
                         p_total_rtot_db   IN OUT NOCOPY
                           ra_customer_trx_lines.extended_amount%type)
IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_tax_util.select_summary()+');
  END IF;

  SELECT nvl(sum(extended_amount),0), nvl(sum(extended_amount),0)
  INTO p_total, p_total_rtot_db
  FROM ra_customer_trx_lines
  WHERE customer_trx_id = p_customer_trx_id
  AND   NVL( link_to_cust_trx_line_id, -10 ) =
        DECODE(p_mode,
              'LINE', p_customer_trx_line_id,
              'ALL',  link_to_cust_trx_line_id,
              -10 )
  AND line_type = 'TAX';

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_trx_tax_util.select_summary()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_trx_tax_util.select_summary()');
       arp_util.debug('select_summary: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
    END IF;
    RAISE;
END select_summary;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_last_line_on_delete                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns whether this is the only tax line for the customer_trx_line_id |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_line_id                               |
 |              OUT:                                                         |
 |              	p_only_tax_line                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-96  Vikas Mahajan          Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE check_last_line_on_delete(p_customer_trx_line_id IN
                                 ra_customer_trx_lines.customer_trx_line_id%type
,
                                    p_only_tax_line_flag OUT NOCOPY BOOLEAN)
IS
      l_only_tax_line_flag varchar2(2);
BEGIN

  arp_util.debug('arp_trx_tax_util.check_last_line_on_delete()+');
  SELECT decode(max(dummy),
                 '', 'N',
                     'Y')
  INTO  l_only_tax_line_flag
  FROM  dual
  WHERE EXISTS
             (SELECT 'deleted last tax line'
              FROM   ra_customer_trx_lines
              WHERE link_to_cust_trx_line_id = p_customer_trx_line_id
              AND line_type = 'TAX'
              having  count(*) = 1
             ) ;

   IF      (l_only_tax_line_flag = 'Y')
   THEN    p_only_tax_line_flag := TRUE;
   ELSE    p_only_tax_line_flag := FALSE;
   END IF;

  arp_util.debug('arp_trx_tax_util.check_last_line_on_delete()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION:  arp_trx_tax_util.check_last_line_on_delete()');
    arp_util.debug('p_customer_trx_line_id = ' || p_customer_trx_line_id);
    RAISE;

END;
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_unique_line                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns whether the new tax line number is unique for the invoice line |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_line_id                               |
 |			p_customer_trx_tax_line_num                          |
 |              OUT:                                                         |
 |              	p_unique_line_flag                                   |
 |              	TRUE  - if line is unique                            |
 |              	FALSE - if line is non unique                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-96  Vikas Mahajan          Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE check_unique_line(p_customer_trx_line_id IN
                                 ra_customer_trx_lines.customer_trx_line_id%type,
                           p_customer_trx_line_num IN
                                 ra_customer_trx_lines.line_number%type,
                           p_unique_line_flag OUT NOCOPY Boolean )
IS
      l_unique_line_flag   varchar2(2);
BEGIN

  arp_util.debug('arp_trx_tax_util.check_unique_line()+');
  SELECT decode(max(dummy),
                 '', 'N',
                     'Y')
  INTO  l_unique_line_flag
  FROM  dual
  WHERE EXISTS
             (SELECT 'unique tax line'
              FROM   ra_customer_trx_lines
              WHERE link_to_cust_trx_line_id = p_customer_trx_line_id
              AND line_type = 'TAX'
              AND line_number = p_customer_trx_line_num
             ) ;

  IF (l_unique_line_flag='Y')
  THEN
      p_unique_line_flag := FALSE;
  ELSE
      p_unique_line_flag := TRUE;
  END IF;

  arp_util.debug('arp_trx_tax_util.check_unique_line()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION:  arp_trx_tax_util.check_unique_line()');
    arp_util.debug(
                '---------- ' ||
                'Parameters for arp_trx_tax_util.check_unique_line() ' ||
                '---------- ');
    arp_util.debug('p_customer_trx_line_id = ' || p_customer_trx_line_id);
    arp_util.debug('p_customer_trx_line_number = ' || p_customer_trx_line_num);

    RAISE;
END;
/*===========================================================================+
 | FUNCTION                                                                  |
 |    balance_due                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns balance due for this tax line                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_customer_trx_line_id                               |
 |              OUT:                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-96  Vikas Mahajan          Created                             |
 |                                                                           |
 +===========================================================================*/


FUNCTION tax_balance(p_prev_cust_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%type,
                     p_cust_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%type )

                   RETURN NUMBER IS
l_balance_due number;
Begin
  arp_util.debug('arp_trx_tax_util.tax_balance()+');

    /* Calculate Balance Due By Checking Any other Credit Memos
       Which Are Complete */

    SELECT   nvl(sum(extended_amount),0)
    INTO     l_balance_due
    FROM     ra_customer_trx_lines ctl,
             ra_customer_trx       ct
    WHERE    previous_customer_trx_line_id = p_prev_cust_trx_line_id
    AND      customer_trx_line_id         <> p_cust_trx_line_id
    AND      ctl.customer_trx_id = ct.customer_trx_id
    AND      ct.complete_flag = 'Y';

    return(l_balance_due);

    arp_util.debug('arp_trx_tax_util.tax_balance()-');

    EXCEPTION
    WHEN OTHERS THEN
    arp_util.debug('EXCEPTION:  arp_trx_tax_util.tax_balance');
    RAISE;
End;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    check_tax_code                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns whether the  tax code is adhoc or not.                         |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |			p_tax_code                                           |
 |              OUT:                                                         |
 |              	p_adhoc_tax_flag                                     |
 |              	TRUE  - if tax_code is adhoc                         |
 |              	FALSE - if tax_code is non adhoc                     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-96  Vikas Mahajan          Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE check_tax_code(p_tax_code IN
                                 ar_vat_tax.tax_code%type,
                         p_adhoc_tax_flag OUT NOCOPY Boolean )
IS
      l_adhoc_tax_flag   varchar2(2);
BEGIN

  arp_util.debug('arp_trx_tax_util.check_tax_code()+');
  SELECT validate_flag
  INTO  l_adhoc_tax_flag
  FROM  ar_vat_tax
  WHERE  tax_code = p_tax_code;

  IF (l_adhoc_tax_flag='Y')
  THEN
      p_adhoc_tax_flag := TRUE;
  ELSE
      p_adhoc_tax_flag := FALSE;
  END IF;

  arp_util.debug('arp_trx_tax_util.check_tax_code()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION:  arp_trx_tax_util.check_tax_code()');
    arp_util.debug(
                '---------- ' ||
                'Parameters for arp_trx_tax_util.check_tax_code() ' ||
                '---------- ');
    arp_util.debug('p_tax_code = ' || p_tax_code);

    RAISE;
END;
END ARP_TRX_TAX_UTIL;

/
