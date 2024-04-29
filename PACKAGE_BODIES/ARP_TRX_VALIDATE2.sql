--------------------------------------------------------
--  DDL for Package Body ARP_TRX_VALIDATE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TRX_VALIDATE2" AS
/* $Header: ARTUVA4B.pls 115.4 2003/10/10 14:29:48 mraymond ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_trx_tax_date()                                                |
 | DESCRIPTION                                                               |
 |    Validates that all entities that have date ranges are still valid after|
 |    the transaction date changes.                                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_trx_date                                               |
 |                  p_customer_trx_id                                        |
 |                  p_affect_tax_flag                                        |
 |              OUT:                                                         |
 |                  p_result_flag                                            |
 |                                                                           |
 |         IN / OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/


PROCEDURE validate_trx_tax_date( p_trx_date                  IN  DATE,
                             p_customer_trx_id               IN  NUMBER,
                             p_result_flag                  OUT NOCOPY boolean
                       ) IS

   l_temp    varchar2(128);

BEGIN

   arp_util.debug('ARP_TRX_VALIDATE.validate_trx_tax_date()+');

   p_result_flag := TRUE;


     /*---------------------+
      |  Validate tax code  |
      +---------------------*/

     arp_util.debug('Validate trx lines tax code');

     BEGIN

                 SELECT 'Invalid tax Code'
                 INTO    l_temp
                 From    Dual
                 Where exists
                 ( Select line.vat_tax_id
                 FROM   ra_customer_trx_lines line,
                        ar_vat_tax tax
                 WHERE  line.customer_trx_id      = p_customer_trx_id
                 AND    line.line_type            = 'LINE'
                 AND    line.vat_tax_id           = tax.vat_tax_id
                 AND    p_trx_date  NOT BETWEEN tax.start_date
                                             AND NVL(tax.end_date,
                                                     p_trx_date));


          EXCEPTION
          WHEN NO_DATA_FOUND THEN
                         p_result_flag := FALSE;

     END;


   arp_util.debug('ARP_TRX_VALIDATE.validate_trx_tax_code()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  ARP_TRX_VALIDATE.validate_trx_date()');
        RAISE;

END;

PROCEDURE tax_flag(p_tax_flag IN varchar2) IS

BEGIN

     pg_tax_flag := p_tax_flag;
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_util.debug('Value is '|| p_tax_flag);
     END IF;

END tax_flag;

end arp_TRX_VALIDATE2;

/
