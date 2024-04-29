--------------------------------------------------------
--  DDL for Package Body ARP_DELETE_DIST_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DELETE_DIST_COVER" AS
/* $Header: ARTLGDDB.pls 115.4 2003/10/10 14:29:21 mraymond ship $ */

pg_msg_level_debug    binary_integer;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_dist_cover						             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a dist record and                        |
 |    delete a dist line.                                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |                    p_cust_trx_line_gl_dist_id                             |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_cust_trx_line_salesrep_id                            |
 |                    p_account_class                                        |
 |                    p_percent                                              |
 |                    p_amount                                               |
 |                    p_acctd_amount                                         |
 |                    p_gl_date                                              |
 |                    p_original_gl_date                                     |
 |                    p_gl_posted_date                                       |
 |                    p_code_combination_id                                  |
 |                    p_concatenated_segments                                |
 |                    p_collected_tax_ccid                                   |
 |                    p_collected_tax_concat_seg                             |
 |                    p_comments                                             |
 |                    p_account_set_flag                                     |
 |                    p_latest_rec_flag                                      |
 |                    p_ussgl_transaction_code                               |
 |                    p_ussgl_trx_code_context                               |
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
 |                    p_posting_control_id                                   |
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
 |     12-OCT-95  Martin Johnson      Created                                |
 |     05-JAN-99  Tasman Tang         Added new parameters collected_tax_ccid|
 |                                    and collected_tax_concat_seg for       |
 |                                    deferred tax                           |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE delete_dist_cover(
           p_form_name                      IN varchar2,
           p_form_version                   IN number,
           p_cust_trx_line_gl_dist_id       IN
             ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type,
           p_customer_trx_id                IN
             ra_cust_trx_line_gl_dist.customer_trx_id%type,
           p_customer_trx_line_id           IN
             ra_cust_trx_line_gl_dist.customer_trx_line_id %type,
           p_cust_trx_line_salesrep_id      IN
             ra_cust_trx_line_gl_dist.cust_trx_line_salesrep_id%type,
           p_account_class                  IN
             ra_cust_trx_line_gl_dist.account_class%type,
           p_percent                        IN
             ra_cust_trx_line_gl_dist.percent%type,
           p_amount                         IN
             ra_cust_trx_line_gl_dist.amount%type,
           p_gl_date                        IN
             ra_cust_trx_line_gl_dist.gl_date%type,
           p_original_gl_date               IN
             ra_cust_trx_line_gl_dist.original_gl_date%type,
           p_gl_posted_date                 IN
             ra_cust_trx_line_gl_dist.gl_posted_date%type,
           p_code_combination_id            IN
             ra_cust_trx_line_gl_dist.code_combination_id%type,
           p_concatenated_segments          IN
             ra_cust_trx_line_gl_dist.concatenated_segments%type,
           p_collected_tax_ccid             IN
             ra_cust_trx_line_gl_dist.collected_tax_ccid%type,
           p_collected_tax_concat_seg       IN
             ra_cust_trx_line_gl_dist.collected_tax_concat_seg%type,
           p_comments                       IN
             ra_cust_trx_line_gl_dist.comments%type,
           p_account_set_flag               IN
             ra_cust_trx_line_gl_dist.account_set_flag%type,
           p_latest_rec_flag                IN
             ra_cust_trx_line_gl_dist.latest_rec_flag%type,
           p_ussgl_transaction_code         IN
             ra_cust_trx_line_gl_dist.ussgl_transaction_code%type,
           p_ussgl_trx_code_context         IN
             ra_cust_trx_line_gl_dist.ussgl_transaction_code_context%type,
           p_attribute_category             IN
             ra_cust_trx_line_gl_dist.attribute_category%type,
           p_attribute1                     IN
             ra_cust_trx_line_gl_dist.attribute1%type,
           p_attribute2                     IN
             ra_cust_trx_line_gl_dist.attribute2%type,
           p_attribute3                     IN
             ra_cust_trx_line_gl_dist.attribute3%type,
           p_attribute4                     IN
             ra_cust_trx_line_gl_dist.attribute4%type,
           p_attribute5                     IN
             ra_cust_trx_line_gl_dist.attribute5%type,
           p_attribute6                     IN
             ra_cust_trx_line_gl_dist.attribute6%type,
           p_attribute7                     IN
             ra_cust_trx_line_gl_dist.attribute7%type,
           p_attribute8                     IN
             ra_cust_trx_line_gl_dist.attribute8%type,
           p_attribute9                     IN
             ra_cust_trx_line_gl_dist.attribute9%type,
           p_attribute10                    IN
             ra_cust_trx_line_gl_dist.attribute10%type,
           p_attribute11                    IN
             ra_cust_trx_line_gl_dist.attribute11%type,
           p_attribute12                    IN
             ra_cust_trx_line_gl_dist.attribute12%type,
           p_attribute13                    IN
             ra_cust_trx_line_gl_dist.attribute13%type,
           p_attribute14                    IN
             ra_cust_trx_line_gl_dist.attribute14%type,
           p_attribute15                    IN
             ra_cust_trx_line_gl_dist.attribute15%type,
           p_posting_control_id             IN
             ra_cust_trx_line_gl_dist.posting_control_id%type )
IS

      l_dist_rec ra_cust_trx_line_gl_dist%rowtype;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_process_dist.delete_dist_cover()+',
                     pg_msg_level_debug);
      END IF;

     /*------------------------------------------------+
      |  Populate the dist record group with           |
      |  the values passed in as parameters.           |
      +------------------------------------------------*/

      l_dist_rec.customer_trx_id                := p_customer_trx_id;
      l_dist_rec.customer_trx_line_id           := p_customer_trx_line_id;
      l_dist_rec.cust_trx_line_salesrep_id      := p_cust_trx_line_salesrep_id;
      l_dist_rec.account_class                  := p_account_class;
      l_dist_rec.percent                        := p_percent;
      l_dist_rec.amount                         := p_amount;
      l_dist_rec.gl_date                        := p_gl_date;
      l_dist_rec.original_gl_date               := p_original_gl_date;
      l_dist_rec.gl_posted_date                 := p_gl_posted_date;
      l_dist_rec.code_combination_id            := p_code_combination_id;
      l_dist_rec.concatenated_segments          := p_concatenated_segments;
      l_dist_rec.collected_tax_ccid             := p_collected_tax_ccid;
      l_dist_rec.collected_tax_concat_seg       := p_collected_tax_concat_seg;
      l_dist_rec.comments                       := p_comments;
      l_dist_rec.account_set_flag               := p_account_set_flag;
      l_dist_rec.latest_rec_flag                := p_latest_rec_flag;
      l_dist_rec.ussgl_transaction_code         := p_ussgl_transaction_code;
      l_dist_rec.ussgl_transaction_code_context := p_ussgl_trx_code_context;
      l_dist_rec.attribute_category             := p_attribute_category;
      l_dist_rec.attribute1                     := p_attribute1;
      l_dist_rec.attribute2                     := p_attribute2;
      l_dist_rec.attribute3                     := p_attribute3;
      l_dist_rec.attribute4                     := p_attribute4;
      l_dist_rec.attribute5                     := p_attribute5;
      l_dist_rec.attribute6                     := p_attribute6;
      l_dist_rec.attribute7                     := p_attribute7;
      l_dist_rec.attribute8                     := p_attribute8;
      l_dist_rec.attribute9                     := p_attribute9;
      l_dist_rec.attribute10                    := p_attribute10;
      l_dist_rec.attribute11                    := p_attribute11;
      l_dist_rec.attribute12                    := p_attribute12;
      l_dist_rec.attribute13                    := p_attribute13;
      l_dist_rec.attribute14                    := p_attribute14;
      l_dist_rec.attribute15                    := p_attribute15;
      l_dist_rec.posting_control_id             := p_posting_control_id;

     /*----------------------------------------+
      |  Call the standard dist entity handler |
      +----------------------------------------*/

      arp_process_dist.delete_dist(
                   p_form_name,
                   p_form_version,
                   p_cust_trx_line_gl_dist_id,
                   p_customer_trx_id,
                   l_dist_rec );

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('arp_process_dist.delete_dist_cover()-',
                     pg_msg_level_debug);
      END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_process_dist.delete_dist_cover()',
                   pg_msg_level_debug);
       arp_util.debug('------- parameters for delete_dist_cover() ' ||
                   '---------',
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_form_name                 = ' || p_form_name,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_form_version              = ' || p_form_version,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_cust_trx_line_gl_dist_id  = ' ||
                     p_cust_trx_line_gl_dist_id,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_customer_trx_id           = ' || p_customer_trx_id,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_customer_trx_line_id      = ' || p_customer_trx_line_id,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_cust_trx_line_salesrep_id = ' ||
                     p_cust_trx_line_salesrep_id,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_account_class             = ' || p_account_class,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_percent                   = ' || p_percent,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_amount                    = ' || p_amount,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_gl_date                   = ' || p_gl_date,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_gl_posted_date            = ' || p_gl_posted_date,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_original_gl_date          = ' || p_original_gl_date,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_code_combination_id       = ' || p_code_combination_id,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_concatenated_segments     = ' || p_concatenated_segments,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_collected_tax_ccid        = ' || p_collected_tax_ccid,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_collected_tax_concat_seg  = ' || p_collected_tax_concat_seg,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_comments                  = ' || p_comments,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_account_set_flag          = ' || p_account_set_flag,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_latest_rec_flag           = ' || p_latest_rec_flag,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_ussgl_transaction_code    = ' ||
                      p_ussgl_transaction_code,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_ussgl_trx_code_context    = ' ||
                      p_ussgl_trx_code_context,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute_category        = ' || p_attribute_category,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute1                = ' || p_attribute1,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute2                = ' || p_attribute2,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute3                = ' || p_attribute3,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute4                = ' || p_attribute4,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute5                = ' || p_attribute5,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute6                = ' || p_attribute6,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute7                = ' || p_attribute7,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute8                = ' || p_attribute8,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute9                = ' || p_attribute9,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute10               = ' || p_attribute10,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute11               = ' || p_attribute11,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute12               = ' || p_attribute12,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute13               = ' || p_attribute13,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute14               = ' || p_attribute14,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_attribute15               = ' || p_attribute15,
                   pg_msg_level_debug);
       arp_util.debug('delete_dist_cover: ' || 'p_posting_control_id        = ' || p_posting_control_id,
                   pg_msg_level_debug);
    END IF;

    RAISE;

END delete_dist_cover;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

   pg_msg_level_debug := arp_global.MSG_LEVEL_DEBUG;

END ARP_DELETE_DIST_COVER;

/
