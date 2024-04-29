--------------------------------------------------------
--  DDL for Package Body ARP_CTL_FREIGHT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CTL_FREIGHT_PKG" AS
/* $Header: ARTCTLFB.pls 115.4 2003/10/10 14:27:40 mraymond ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    select_summary_freight                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects the total freight amount for a given transaction               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_amount_total                                         |
 |                    p_amount_total_rtot_db                                 |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     25-SEP-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE select_summary_freight(
   p_customer_trx_id        IN  number,
   p_amount_total          OUT NOCOPY  number,
   p_amount_total_rtot_db  OUT NOCOPY  number) IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_ctl_pkg.select_summary_freight()+');
   END IF;

   SELECT NVL( SUM( NVL(extended_amount,  0 ) ), 0),
          NVL( SUM( NVL(extended_amount,  0 ) ), 0)
   INTO   p_amount_total,
          p_amount_total_rtot_db
   FROM   ra_customer_trx_lines
   WHERE  customer_trx_id = p_customer_trx_id
   AND    line_type       = 'FREIGHT';

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_ctl_pkg.select_summary_freight()-');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('EXCEPTION:  arp_ctl_pkg.select_summary_freight()');
   END IF;
   RAISE;

END select_summary_freight;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_frt_cover                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Selects the total freight amount for a given transaction               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_link_to_cust_trx_line_id                             |
 |                    p_previous_customer_trx_id                             |
 |                    p_previous_cust_trx_line_id                            |
 |                    p_line_number                                          |
 |                    p_line_type                                            |
 |                    p_extended_amount                                      |
 |                    p_attribute_category                                   |
 |                    p_attribute1-15                                        |
 |                    p_interface_line_context                               |
 |                    p_interface_line_attribute1-15                         |
 |                    p_default_ussgl_code_context                           |
 |                    p_default_ussgl_trx_code                               |
 |              OUT:                                                         |
 |                    None                                                   |
 |          IN/ OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-OCT-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE lock_compare_frt_cover(
  p_customer_trx_line_id     IN
                   ra_customer_trx_lines.customer_trx_line_id%type,
  p_customer_trx_id          IN
                   ra_customer_trx_lines.customer_trx_id%type,
  p_link_to_cust_trx_line_id IN
                   ra_customer_trx_lines.link_to_cust_trx_line_id%type,
  p_previous_customer_trx_id IN
                   ra_customer_trx_lines.previous_customer_trx_id%type,
  p_previous_cust_trx_line_id IN
               ra_customer_trx_lines.previous_customer_trx_line_id%type,
  p_line_number              IN ra_customer_trx_lines.line_number%type,
  p_line_type                     IN ra_customer_trx_lines.line_type%type,
  p_extended_amount               IN ra_customer_trx_lines.extended_amount%type,
  p_attribute_category            IN
                        ra_customer_trx_lines.attribute_category%type,
  p_attribute1                    IN ra_customer_trx_lines.attribute1%type,
  p_attribute2                    IN ra_customer_trx_lines.attribute2%type,
  p_attribute3                    IN ra_customer_trx_lines.attribute3%type,
  p_attribute4                    IN ra_customer_trx_lines.attribute4%type,
  p_attribute5                    IN ra_customer_trx_lines.attribute5%type,
  p_attribute6                    IN ra_customer_trx_lines.attribute6%type,
  p_attribute7                    IN ra_customer_trx_lines.attribute7%type,
  p_attribute8                    IN ra_customer_trx_lines.attribute8%type,
  p_attribute9                    IN ra_customer_trx_lines.attribute9%type,
  p_attribute10                   IN ra_customer_trx_lines.attribute10%type,
  p_attribute11                   IN ra_customer_trx_lines.attribute11%type,
  p_attribute12                   IN ra_customer_trx_lines.attribute12%type,
  p_attribute13                   IN ra_customer_trx_lines.attribute13%type,
  p_attribute14                   IN ra_customer_trx_lines.attribute14%type,
  p_attribute15                   IN ra_customer_trx_lines.attribute15%type,
  p_interface_line_context        IN
                        ra_customer_trx_lines.interface_line_context%type,
  p_interface_line_attribute1     IN
                        ra_customer_trx_lines.interface_line_attribute1%type,
  p_interface_line_attribute2     IN
                        ra_customer_trx_lines.interface_line_attribute2%type,
  p_interface_line_attribute3     IN
                        ra_customer_trx_lines.interface_line_attribute3%type,
  p_interface_line_attribute4     IN
                        ra_customer_trx_lines.interface_line_attribute4%type,
  p_interface_line_attribute5     IN
                        ra_customer_trx_lines.interface_line_attribute5%type,
  p_interface_line_attribute6     IN
                        ra_customer_trx_lines.interface_line_attribute6%type,
  p_interface_line_attribute7     IN
                        ra_customer_trx_lines.interface_line_attribute7%type,
  p_interface_line_attribute8     IN
                        ra_customer_trx_lines.interface_line_attribute8%type,
  p_interface_line_attribute9     IN
                        ra_customer_trx_lines.interface_line_attribute9%type,
  p_interface_line_attribute10    IN
                        ra_customer_trx_lines.interface_line_attribute10%type,
  p_interface_line_attribute11    IN
                        ra_customer_trx_lines.interface_line_attribute11%type,
  p_interface_line_attribute12    IN
                        ra_customer_trx_lines.interface_line_attribute12%type,
  p_interface_line_attribute13    IN
                        ra_customer_trx_lines.interface_line_attribute13%type,
  p_interface_line_attribute14    IN
                        ra_customer_trx_lines.interface_line_attribute14%type,
  p_interface_line_attribute15    IN
                        ra_customer_trx_lines.interface_line_attribute15%type,
  p_default_ussgl_code_context IN
                     ra_customer_trx_lines.default_ussgl_trx_code_context%type,
  p_default_ussgl_trx_code IN
                     ra_customer_trx_lines.default_ussgl_transaction_code%type)
IS
  l_frt_rec        ra_customer_trx_lines%rowtype;
BEGIN

    arp_util.debug('arp_ctl_pkg.lock_compare_frt_cover()+');

     /*------------------------------------------------+
      |  Populate the line record with the values      |
      |  passed in as parameters.                      |
      +------------------------------------------------*/
   arp_ctl_pkg.set_to_dummy(l_frt_rec);

   l_frt_rec.customer_trx_id               := p_customer_trx_id;
   l_frt_rec.customer_trx_line_id          := p_customer_trx_line_id;
   l_frt_rec.line_type                     := p_line_type;
   l_frt_rec.line_number                   := p_line_number;
   l_frt_rec.extended_amount               := p_extended_amount;
   l_frt_rec.previous_customer_trx_id      := p_previous_customer_trx_id;
   l_frt_rec.previous_customer_trx_line_id := p_previous_cust_trx_line_id;
   l_frt_rec.link_to_cust_trx_line_id      := p_link_to_cust_trx_line_id;
   l_frt_rec.attribute_category            := p_attribute_category;
   l_frt_rec.attribute1                    := p_attribute1;
   l_frt_rec.attribute2                    := p_attribute2;
   l_frt_rec.attribute3                    := p_attribute3;
   l_frt_rec.attribute4                    := p_attribute4;
   l_frt_rec.attribute5                    := p_attribute5;
   l_frt_rec.attribute6                    := p_attribute6;
   l_frt_rec.attribute7                    := p_attribute7;
   l_frt_rec.attribute8                    := p_attribute8;
   l_frt_rec.attribute9                    := p_attribute9;
   l_frt_rec.attribute10                   := p_attribute10;
   l_frt_rec.attribute11                   := p_attribute11;
   l_frt_rec.attribute12                   := p_attribute12;
   l_frt_rec.attribute13                   := p_attribute13;
   l_frt_rec.attribute14                   := p_attribute14;
   l_frt_rec.attribute15                   := p_attribute15;

   l_frt_rec.interface_line_context        := p_interface_line_context;
   l_frt_rec.interface_line_attribute1     := p_interface_line_attribute1;
   l_frt_rec.interface_line_attribute2     := p_interface_line_attribute2;
   l_frt_rec.interface_line_attribute3     := p_interface_line_attribute3;
   l_frt_rec.interface_line_attribute4     := p_interface_line_attribute4;
   l_frt_rec.interface_line_attribute5     := p_interface_line_attribute5;
   l_frt_rec.interface_line_attribute6     := p_interface_line_attribute6;
   l_frt_rec.interface_line_attribute7     := p_interface_line_attribute7;
   l_frt_rec.interface_line_attribute8     := p_interface_line_attribute8;
   l_frt_rec.interface_line_attribute9     := p_interface_line_attribute9;
   l_frt_rec.interface_line_attribute10    := p_interface_line_attribute10;
   l_frt_rec.interface_line_attribute11    := p_interface_line_attribute11;
   l_frt_rec.interface_line_attribute12    := p_interface_line_attribute12;
   l_frt_rec.interface_line_attribute13    := p_interface_line_attribute13;
   l_frt_rec.interface_line_attribute14    := p_interface_line_attribute14;
   l_frt_rec.interface_line_attribute15    := p_interface_line_attribute15;

   l_frt_rec.default_ussgl_trx_code_context := p_default_ussgl_code_context;
   l_frt_rec.default_ussgl_transaction_code := p_default_ussgl_trx_code;

   arp_ctl_pkg.lock_compare_p(l_frt_rec, p_customer_trx_line_id);

   arp_util.debug('arp_ctl_pkg.lock_compare_frt_cover()-');

EXCEPTION

  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_ctl_pkg.lock_compare_frt_cover()');

    arp_util.debug('customer_trx_id            : '||p_customer_trx_id);
    arp_util.debug('customer_trx_line_id       : '||p_customer_trx_line_id);
    arp_util.debug('line_type                  : '||p_line_type);
    arp_util.debug('line_number                : '||p_line_number);
    arp_util.debug('extended_amount            : '||p_extended_amount);
    arp_util.debug('previous_customer_trx_id   : '||
                   p_previous_customer_trx_id);
    arp_util.debug('previous_customer_trx_line_id : '||
                   p_previous_cust_trx_line_id);
    arp_util.debug('link_to_cust_trx_line_id   : '||
                   p_link_to_cust_trx_line_id);
    arp_util.debug('attribute_category         : '||p_attribute_category);
    arp_util.debug('attribute1                 : '||p_attribute1);
    arp_util.debug('attribute2                 : '||p_attribute2);
    arp_util.debug('attribute3                 : '||p_attribute3);
    arp_util.debug('attribute4                 : '||p_attribute4);
    arp_util.debug('attribute5                 : '||p_attribute5);
    arp_util.debug('attribute6                 : '||p_attribute6);
    arp_util.debug('attribute7                 : '||p_attribute7);
    arp_util.debug('attribute8                 : '||p_attribute8);
    arp_util.debug('attribute9                 : '||p_attribute9);
    arp_util.debug('attribute10                : '||p_attribute10);
    arp_util.debug('attribute11                : '||p_attribute11);
    arp_util.debug('attribute12                : '||p_attribute12);
    arp_util.debug('attribute13                : '||p_attribute13);
    arp_util.debug('attribute14                : '||p_attribute14);
    arp_util.debug('attribute15                : '||p_attribute15);

    arp_util.debug('interface_line_context     : '||
                   p_interface_line_context);
    arp_util.debug('interface_line_attribute1  : '||
                   p_interface_line_attribute1);
    arp_util.debug('interface_line_attribute2  : '||
                   p_interface_line_attribute2);
    arp_util.debug('interface_line_attribute3  : '||
                   p_interface_line_attribute3);
    arp_util.debug('interface_line_attribute4  : '||
                   p_interface_line_attribute4);
    arp_util.debug('interface_line_attribute5  : '||
                   p_interface_line_attribute5);
    arp_util.debug('interface_line_attribute6  : '||
                   p_interface_line_attribute6);
    arp_util.debug('interface_line_attribute7  : '||
                   p_interface_line_attribute7);
    arp_util.debug('interface_line_attribute8  : '||
                   p_interface_line_attribute8);
    arp_util.debug('interface_line_attribute9  : '||
                   p_interface_line_attribute9);
    arp_util.debug('interface_line_attribute10 : '||
                   p_interface_line_attribute10);
    arp_util.debug('interface_line_attribute11 : '||
                   p_interface_line_attribute11);
    arp_util.debug('interface_line_attribute12 : '||
                   p_interface_line_attribute12);
    arp_util.debug('interface_line_attribute13 : '||
                   p_interface_line_attribute13);
    arp_util.debug('interface_line_attribute14 : '||
                   p_interface_line_attribute14);
    arp_util.debug('interface_line_attribute15 : '||
                   p_interface_line_attribute15);

    arp_util.debug('default_ussgl_trx_code_context : '||
                   p_default_ussgl_code_context);
    arp_util.debug('default_ussgl_transaction_code : '||
                   p_default_ussgl_trx_code);

    RAISE;

END;

END ARP_CTL_FREIGHT_PKG;

/
