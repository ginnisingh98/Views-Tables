--------------------------------------------------------
--  DDL for Package Body ARP_CTL_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CTL_SUM_PKG" AS
/* $Header: ARTUCTLB.pls 115.4 2003/10/10 14:29:29 mraymond ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_summary                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects the total trx,tax and freight amount for a given transaction   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_line_type                                            |
 |              OUT:                                                         |
 |                    p_amount_total                                         |
 |                    p_amount_total_rtot_db                                 |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-DEC-95  Vikas  Mahajan  Created                                    |
 |                                                                           |
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE select_summary(
   p_customer_trx_id        IN  number,
   p_line_type              IN  varchar2,
   p_amount_total          OUT NOCOPY  number,
   p_amount_total_rtot_db  OUT NOCOPY  number) IS
BEGIN
--   arp_util.debug('arp_ctl_sum_pkg.select_summary()+');
   if ( p_line_type = 'ALL')
   THEN
     SELECT NVL( SUM( NVL(extended_amount,  0 ) ), 0),
            NVL( SUM( NVL(extended_amount,  0 ) ), 0)
     INTO   p_amount_total,
            p_amount_total_rtot_db
     FROM   ra_customer_trx_lines
     WHERE  customer_trx_id = p_customer_trx_id;
  ELSE
     SELECT NVL( SUM( NVL(extended_amount,  0 ) ), 0),
            NVL( SUM( NVL(extended_amount,  0 ) ), 0)
     INTO   p_amount_total,
            p_amount_total_rtot_db
     FROM   ra_customer_trx_lines
     WHERE  customer_trx_id = p_customer_trx_id
     AND    line_type       = p_line_type;

--     arp_util.debug('arp_ctl_sum_pkg.select_summary()-');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
--   arp_util.debug('EXCEPTION:  arp_ctl_sum_pkg.select_summary()');
   RAISE;

END select_summary;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_summary                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the total trx,tax and freight amount for a given transaction      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_line_type                                            |
 |              IN/ OUT:                                                     |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    :                                                              |
 |                    p_amount_total                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-Feb-98  Ramakant Alat   Created                                    |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_summary(
        p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE,
        p_line_type              IN  varchar2
) return NUMBER  IS

        p_amount_total           NUMBER;
        p_amount_total_rtot      NUMBER;
BEGIN

--   arp_util.debug('arp_ctl_sum_pkg.geT_summary()+');

     select_summary( p_customer_trx_id,
                     p_line_type,
                     p_amount_total,
                     p_amount_total_rtot);

--   arp_util.debug('arp_ctl_sum_pkg.get_summary()-');
        return p_amount_total;

EXCEPTION

WHEN OTHERS THEN
--   arp_util.debug('EXCEPTION:  arp_ctl_sum_pkg.get_summary()');
            RAISE;

END get_summary;


END ARP_CTL_SUM_PKG;

/
