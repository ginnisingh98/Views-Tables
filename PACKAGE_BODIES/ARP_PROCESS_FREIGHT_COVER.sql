--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_FREIGHT_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_FREIGHT_COVER" AS
/* $Header: ARTEFR2B.pls 115.4 2003/10/10 14:28:18 mraymond ship $ */

pg_number_dummy number;
pg_date_dummy date;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_freight_cover                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for the freight entity handler procedure insert_freight          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_process_freight.insert_freight                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_form_name                                            |
 |                    p_form_version                                         |
 |                    p_customer_trx_id                                      |
 |                    p_line_type                                            |
 |                    p_line_number                                          |
 |                    p_extended_amount                                      |
 |                    p_revenue_amount                                       |
 |                    p_previous_customer_trx_id                             |
 |                    p_previous_cust_trx_line_id                            |
 |                    p_link_to_cust_trx_line_id                             |
 |                    p_attribute_category                                   |
 |                    p_attribute1-15                                        |
 |                    p_interface_line_context                               |
 |                    p_interface_line_attribute1-15                         |
 |                    p_trx_class                                            |
 |                    p_gl_date                                              |
 |                    p_frt_ccid                                             |
 |              OUT:                                                         |
 |                    p_customer_trx_line_id                                 |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |      12-JUL-95       Subash Chadalavada              Created              |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_freight_cover(
  p_form_name                     IN varchar2,
  p_form_version                  IN number,
  p_customer_trx_id               IN ra_customer_trx_lines.customer_trx_id%type,
  p_line_type                     IN ra_customer_trx_lines.line_type%type,
  p_line_number                   IN ra_customer_trx_lines.line_number%type,
  p_extended_amount               IN ra_customer_trx_lines.extended_amount%type,
  p_revenue_amount                IN ra_customer_trx_lines.revenue_amount%type,
  p_previous_customer_trx_id      IN
                        ra_customer_trx_lines.previous_customer_trx_id%type,
  p_previous_cust_trx_line_id IN
                       ra_customer_trx_lines.previous_customer_trx_line_id%type,
  p_link_to_cust_trx_line_id      IN
                        ra_customer_trx_lines.link_to_cust_trx_line_id%type,
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
                     ra_customer_trx_lines.default_ussgl_transaction_code%type,
  p_trx_class                     IN ra_cust_trx_types.type%type,
  p_gl_date                       IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid                      IN
                    ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_customer_trx_line_id         OUT NOCOPY
                    ra_customer_trx_lines.customer_trx_line_id%type,
  p_status                       OUT NOCOPY varchar2)
IS

  l_frt_rec                 ra_customer_trx_lines%rowtype;
  l_customer_trx_line_id    ra_customer_trx_lines.customer_trx_line_id%type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_freight.insert_freight_cover()+');
   END IF;

   l_frt_rec.customer_trx_id               := p_customer_trx_id;
   l_frt_rec.line_type                     := p_line_type;
   l_frt_rec.line_number                   := p_line_number;
   l_frt_rec.extended_amount               := p_extended_amount;
   l_frt_rec.revenue_amount                := p_revenue_amount;
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

   arp_process_freight.insert_freight(
            p_form_name,
            p_form_version,
            l_frt_rec,
            p_trx_class,
            p_gl_date,
            p_frt_ccid,
            l_customer_trx_line_id,
            p_status);

   p_customer_trx_line_id := l_customer_trx_line_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_process_freight.insert_freight_cover()-');
   END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : arp_process_freight.insert_freight_cover');
       arp_util.debug('insert_freight_cover: ' || 'p_form_name                  : '||p_form_name);
       arp_util.debug('insert_freight_cover: ' || 'p_form_version               : '||p_form_version);
       arp_util.debug('insert_freight_cover: ' || 'p_customer_trx_id            : '||p_customer_trx_id);
       arp_util.debug('insert_freight_cover: ' || 'p_line_type                  : '||p_line_type);
       arp_util.debug('insert_freight_cover: ' || 'p_line_number                : '||p_line_number);
       arp_util.debug('insert_freight_cover: ' || 'p_extended_amount            : '||p_extended_amount);
       arp_util.debug('insert_freight_cover: ' || 'p_revenue_amount             : '||p_revenue_amount);
       arp_util.debug('insert_freight_cover: ' || 'p_previous_customer_trx_id   : '||p_previous_customer_trx_id);
       arp_util.debug('insert_freight_cover: ' || 'p_previous_cust_trx_line_id  : '||p_previous_cust_trx_line_id);
       arp_util.debug('insert_freight_cover: ' || 'p_link_to_cust_trx_line_id   : '||p_link_to_cust_trx_line_id);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute_category         : '||p_attribute_category);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute1                 : '||p_attribute1);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute2                 : '||p_attribute2);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute3                 : '||p_attribute3);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute4                 : '||p_attribute4);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute5                 : '||p_attribute5);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute6                 : '||p_attribute6);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute7                 : '||p_attribute7);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute8                 : '||p_attribute8);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute9                 : '||p_attribute9);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute10                : '||p_attribute10);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute11                : '||p_attribute11);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute12                : '||p_attribute12);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute13                : '||p_attribute13);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute14                : '||p_attribute14);
       arp_util.debug('insert_freight_cover: ' || 'p_attribute15                : '||p_attribute15);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_context     : '||p_interface_line_context);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute1  : '||p_interface_line_attribute1);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute2  : '||p_interface_line_attribute2);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute3  : '||p_interface_line_attribute3);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute4  : '||p_interface_line_attribute4);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute5  : '||p_interface_line_attribute5);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute6  : '||p_interface_line_attribute6);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute7  : '||p_interface_line_attribute7);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute8  : '||p_interface_line_attribute8);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute9  : '||p_interface_line_attribute9);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute10 : '||p_interface_line_attribute10);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute11 : '||p_interface_line_attribute11);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute12 : '||p_interface_line_attribute12);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute13 : '||p_interface_line_attribute13);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute14 : '||p_interface_line_attribute14);
       arp_util.debug('insert_freight_cover: ' || 'p_interface_line_attribute15 : '||p_interface_line_attribute15);
       arp_util.debug('insert_freight_cover: ' || 'p_default_ussgl_code_context : '||p_default_ussgl_code_context);
       arp_util.debug('insert_freight_cover: ' || 'p_default_ussgl_trx_code     : '||p_default_ussgl_trx_code);
       arp_util.debug('insert_freight_cover: ' || 'p_trx_class                  : '||p_trx_class);
       arp_util.debug('insert_freight_cover: ' || 'p_gl_date                    : '||p_gl_date);
       arp_util.debug('insert_freight_cover: ' || 'p_frt_ccid                   : '||p_frt_ccid);
    END IF;

    RAISE;

END insert_freight_cover;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_freight_cover                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Cover for the freight entity handler procedure update_freight          |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_process_freight.update_freight                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_form_name                                             |
 |                   p_form_version                                          |
 |                   p_customer_trx_id                                       |
 |                   p_customer_trx_line_id                                  |
 |                   p_line_type                                             |
 |                   p_line_number                                           |
 |                   p_extended_amount                                       |
 |                   p_revenue_amount                                        |
 |                   p_previous_customer_trx_id                              |
 |                   p_previous_cust_trx_line_id                             |
 |                   p_link_to_cust_trx_line_id                              |
 |                   p_attribute_category                                    |
 |                   p_attribute1 - 15                                       |
 |                   p_interface_line_context                                |
 |                   p_interface_line_attribute1 - 15                        |
 |                   p_default_ussgl_code_context                            |
 |                   p_default_ussgl_trx_code                                |
 |                   p_trx_class                                             |
 |                   p_gl_date                                               |
 |                   p_frt_ccid                                              |
 |                   p_complete_flag                                         |
 |                   p_gl_date                                               |
 |                   p_open_rec_flag                                         |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_freight_cover(
  p_form_name                     IN varchar2,
  p_form_version                  IN number,
  p_customer_trx_id               IN ra_customer_trx_lines.customer_trx_id%type,
  p_customer_trx_line_id          IN
                    ra_customer_trx_lines.customer_trx_line_id%type,
  p_line_type                     IN ra_customer_trx_lines.line_type%type,
  p_line_number                   IN ra_customer_trx_lines.line_number%type,
  p_extended_amount               IN ra_customer_trx_lines.extended_amount%type,
  p_revenue_amount                IN ra_customer_trx_lines.revenue_amount%type,
  p_previous_customer_trx_id      IN
                        ra_customer_trx_lines.previous_customer_trx_id%type,
  p_previous_cust_trx_line_id IN
                       ra_customer_trx_lines.previous_customer_trx_line_id%type,
  p_link_to_cust_trx_line_id      IN
                        ra_customer_trx_lines.link_to_cust_trx_line_id%type,
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
                     ra_customer_trx_lines.default_ussgl_transaction_code%type,
  p_trx_class                     IN ra_cust_trx_types.type%type,
  p_gl_date                       IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid                      IN
                    ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_complete_flag                 IN varchar2,
  p_open_rec_flag                 IN varchar2,
  p_status                       OUT NOCOPY varchar2)
IS

  l_frt_rec    ra_customer_trx_lines%rowtype;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_freight.update_freight_cover()+');
    END IF;

    arp_ctl_pkg.set_to_dummy(l_frt_rec);

   l_frt_rec.customer_trx_id               := p_customer_trx_id;
   l_frt_rec.customer_trx_line_id          := p_customer_trx_line_id;
   l_frt_rec.line_type                     := p_line_type;
   l_frt_rec.line_number                   := p_line_number;
   l_frt_rec.extended_amount               := p_extended_amount;
   l_frt_rec.revenue_amount                := p_revenue_amount;
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

   arp_process_freight.update_freight(
            p_form_name,
            p_form_version,
            p_customer_trx_id,
            p_customer_trx_line_id,
            l_frt_rec,
            p_trx_class,
            p_gl_date,
            p_frt_ccid,
            p_complete_flag,
            p_open_rec_flag,
            p_status);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_freight.update_freight_cover()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : arp_process_freight.update_freight_cover');
       arp_util.debug('update_freight_cover: ' || 'p_form_name                  : '||p_form_name);
       arp_util.debug('update_freight_cover: ' || 'p_form_version               : '||p_form_version);
       arp_util.debug('update_freight_cover: ' || 'p_customer_trx_id            : '||p_customer_trx_id);
       arp_util.debug('update_freight_cover: ' || 'p_customer_trx_line_id       : '||p_customer_trx_line_id);
       arp_util.debug('update_freight_cover: ' || 'p_line_type                  : '||p_line_type);
       arp_util.debug('update_freight_cover: ' || 'p_line_number                : '||p_line_number);
       arp_util.debug('update_freight_cover: ' || 'p_extended_amount            : '||p_extended_amount);
       arp_util.debug('update_freight_cover: ' || 'p_revenue_amount             : '||p_revenue_amount);
       arp_util.debug('update_freight_cover: ' || 'p_previous_customer_trx_id   : '||p_previous_customer_trx_id);
       arp_util.debug('update_freight_cover: ' || 'p_previous_cust_trx_line_id  : '||p_previous_cust_trx_line_id);
       arp_util.debug('update_freight_cover: ' || 'p_link_to_cust_trx_line_id   : '||p_link_to_cust_trx_line_id);
       arp_util.debug('update_freight_cover: ' || 'p_attribute_category         : '||p_attribute_category);
       arp_util.debug('update_freight_cover: ' || 'p_attribute1                 : '||p_attribute1);
       arp_util.debug('update_freight_cover: ' || 'p_attribute2                 : '||p_attribute2);
       arp_util.debug('update_freight_cover: ' || 'p_attribute3                 : '||p_attribute3);
       arp_util.debug('update_freight_cover: ' || 'p_attribute4                 : '||p_attribute4);
       arp_util.debug('update_freight_cover: ' || 'p_attribute5                 : '||p_attribute5);
       arp_util.debug('update_freight_cover: ' || 'p_attribute6                 : '||p_attribute6);
       arp_util.debug('update_freight_cover: ' || 'p_attribute7                 : '||p_attribute7);
       arp_util.debug('update_freight_cover: ' || 'p_attribute8                 : '||p_attribute8);
       arp_util.debug('update_freight_cover: ' || 'p_attribute9                 : '||p_attribute9);
       arp_util.debug('update_freight_cover: ' || 'p_attribute10                : '||p_attribute10);
       arp_util.debug('update_freight_cover: ' || 'p_attribute11                : '||p_attribute11);
       arp_util.debug('update_freight_cover: ' || 'p_attribute12                : '||p_attribute12);
       arp_util.debug('update_freight_cover: ' || 'p_attribute13                : '||p_attribute13);
       arp_util.debug('update_freight_cover: ' || 'p_attribute14                : '||p_attribute14);
       arp_util.debug('update_freight_cover: ' || 'p_attribute15                : '||p_attribute15);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_context     : '||p_interface_line_context);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute1  : '||p_interface_line_attribute1);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute2  : '||p_interface_line_attribute2);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute3  : '||p_interface_line_attribute3);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute4  : '||p_interface_line_attribute4);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute5  : '||p_interface_line_attribute5);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute6  : '||p_interface_line_attribute6);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute7  : '||p_interface_line_attribute7);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute8  : '||p_interface_line_attribute8);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute9  : '||p_interface_line_attribute9);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute10 : '||p_interface_line_attribute10);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute11 : '||p_interface_line_attribute11);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute12 : '||p_interface_line_attribute12);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute13 : '||p_interface_line_attribute13);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute14 : '||p_interface_line_attribute14);
       arp_util.debug('update_freight_cover: ' || 'p_interface_line_attribute15 : '||p_interface_line_attribute15);
       arp_util.debug('update_freight_cover: ' || 'p_default_ussgl_code_context : '||p_default_ussgl_code_context);
       arp_util.debug('update_freight_cover: ' || 'p_default_ussgl_trx_code     : '||p_default_ussgl_trx_code);
       arp_util.debug('update_freight_cover: ' || 'p_trx_class                  : '||p_trx_class);
       arp_util.debug('update_freight_cover: ' || 'p_gl_date                    : '||p_gl_date);
       arp_util.debug('update_freight_cover: ' || 'p_frt_ccid                   : '||p_frt_ccid);
       arp_util.debug('update_freight_cover: ' || 'p_complete_flag              : '||p_complete_flag);
       arp_util.debug('update_freight_cover: ' || 'p_open_rec_flag              : '||p_open_rec_flag);
    END IF;

    RAISE;
END update_freight_cover;

END ARP_PROCESS_FREIGHT_COVER;

/
