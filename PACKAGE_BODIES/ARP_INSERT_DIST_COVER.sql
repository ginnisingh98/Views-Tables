--------------------------------------------------------
--  DDL for Package Body ARP_INSERT_DIST_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_INSERT_DIST_COVER" AS
/* $Header: ARTLGDIB.pls 115.7 2003/10/27 19:39:06 mraymond ship $ */

pg_msg_level_debug    binary_integer;

FUNCTION set_original_gl_date(
    p_customer_trx_id      IN ra_customer_trx.customer_trx_id%TYPE
   ,p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE
   ,p_original_gl_date     IN ra_cust_trx_line_gl_dist.gl_date%TYPE
   ,p_account_class        IN ra_cust_trx_line_gl_dist.account_class%TYPE)
RETURN DATE;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_dist_cover						             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a dist record and                        |
 |    inserts a dist line.                                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_form_name					     |
 |		      p_form_version					     |
 |                    p_exchange_rate                                        |
 |                    p_base_currency_code                                   |
 |                    p_base_precision                                       |
 |                    p_base_mau                                             |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_cust_trx_line_salesrep_id                            |
 |                    p_account_class                                        |
 |                    p_percent                                              |
 |                    p_amount                                               |
 |                    p_acctd_amount                                         |
 |                    p_gl_date                                              |
 |                    p_original_gl_date                                     |
 |                    p_code_combination_id                                  |
 |                    p_concatenated_segments                                |
 |		      p_collected_tax_ccid                                   |
 |                    p_collected_tax_concat_seg                             |
 |                    p_comments                                             |
 |                    p_account_set_flag                                     |
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
 |              OUT:                                                         |
 |		      p_cust_trx_line_gl_dist_id                             |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-OCT-95  Martin Johnson      Created                                |
 |     05-JAN-99  Tasman Tang	      Added new parameters collected_tax_ccid|
 |				      and collected_tax_concat_seg for       |
 |				      deferred tax		             |
 |     12-DEC-02  Jon Beckett         Bug 2569911 - Call to new function     |
 |                                    set_original_gl_date to set the correct|
 |                                    value of original GL date for a rule   |
 |                                    based line to ensure inclusion in CMs  |
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE insert_dist_cover(
           p_form_name                      IN varchar2,
           p_form_version                   IN number,
           p_exchange_rate                  IN
             ra_customer_trx.exchange_rate%type,
           p_base_currency_code             IN
             fnd_currencies.currency_code%type,
           p_base_precision                 IN
             fnd_currencies.precision%type,
           p_base_mau                       IN
             fnd_currencies.minimum_accountable_unit%type,
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
           p_acctd_amount                   IN
             ra_cust_trx_line_gl_dist.acctd_amount%type,
           p_gl_date                        IN
             ra_cust_trx_line_gl_dist.gl_date%type,
           p_original_gl_date               IN
             ra_cust_trx_line_gl_dist.original_gl_date%type,
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
           p_cust_trx_line_gl_dist_id       OUT NOCOPY
             ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%type)
IS

      l_dist_rec ra_cust_trx_line_gl_dist%rowtype;

BEGIN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('arp_process_dist.insert_dist_cover()+');
      END IF;

     /*-----------------------------------------+
      |  Populate the dist record group with    |
      |  the values passed in as parameters.    |
      +-----------------------------------------*/

      l_dist_rec.customer_trx_id                := p_customer_trx_id;
      l_dist_rec.customer_trx_line_id           := p_customer_trx_line_id;
      l_dist_rec.cust_trx_line_salesrep_id      := p_cust_trx_line_salesrep_id;
      l_dist_rec.account_class                  := p_account_class;
      l_dist_rec.percent                        := p_percent;
      l_dist_rec.amount                         := p_amount;
      l_dist_rec.acctd_amount                   := p_acctd_amount;
      l_dist_rec.gl_date                        := p_gl_date;
      /* Bug 2569911 - set original GL date to valid value */
      l_dist_rec.original_gl_date               := set_original_gl_date
                                                      (p_customer_trx_id
                                                      ,p_customer_trx_line_id
                                                      ,p_original_gl_date
                                                      ,p_account_class);
      l_dist_rec.code_combination_id            := p_code_combination_id;
      l_dist_rec.concatenated_segments          := p_concatenated_segments;
      l_dist_rec.collected_tax_ccid	        := p_collected_tax_ccid;
      l_dist_rec.collected_tax_concat_seg	:= p_collected_tax_concat_seg;
      l_dist_rec.comments                       := p_comments;
      l_dist_rec.account_set_flag               := p_account_set_flag;
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

     /*----------------------------------------+
      |  Call the standard dist entity handler |
      +----------------------------------------*/

      arp_process_dist.insert_dist(
                   p_form_name,
                   p_form_version,
                   l_dist_rec,
                   p_exchange_rate,
                   p_base_currency_code,
                   p_base_precision,
                   p_base_mau,
                   p_cust_trx_line_gl_dist_id );

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('arp_process_dist.insert_dist_cover()-');
      END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION:  arp_process_dist.insert_dist_cover()',
                   'plsql');
       arp_standard.debug('------- parameters for insert_dist_cover() ' ||
                   '---------',
                   'plsql');
       arp_standard.debug(  'p_form_name                 = ' || p_form_name,
                   'plsql');
       arp_standard.debug(  'p_form_version              = ' || p_form_version,
                   'plsql');
       arp_standard.debug(  'p_exchange_rate             = ' || p_exchange_rate,
                   'plsql');
       arp_standard.debug(  'p_base_currency_code        = ' || p_base_currency_code,
                   'plsql');
       arp_standard.debug(  'p_base_precision            = ' || p_base_precision,
                   'plsql');
       arp_standard.debug(  'p_base_mau                  = ' || p_base_mau,
                   'plsql');
       arp_standard.debug(  'p_customer_trx_id           = ' || p_customer_trx_id,
                   'plsql');
       arp_standard.debug(  'p_customer_trx_line_id      = ' || p_customer_trx_line_id,
                   'plsql');
       arp_standard.debug(  'p_cust_trx_line_salesrep_id = ' ||
                     p_cust_trx_line_salesrep_id,
                   'plsql');
       arp_standard.debug(  'p_account_class             = ' || p_account_class,
                   'plsql');
       arp_standard.debug(  'p_percent                   = ' || p_percent,
                   'plsql');
       arp_standard.debug(  'p_amount                    = ' || p_amount,
                   'plsql');
       arp_standard.debug(  'p_acctd_amount              = ' || p_acctd_amount,
                   'plsql');
       arp_standard.debug(  'p_gl_date                   = ' || p_gl_date,
                   'plsql');
       arp_standard.debug(  'p_original_gl_date          = ' || p_original_gl_date,
                   'plsql');
       arp_standard.debug(  'p_code_combination_id       = ' || p_code_combination_id,
                   'plsql');
       arp_standard.debug(  'p_concatenated_segments     = ' || p_concatenated_segments,
                   'plsql');
       arp_standard.debug(  'p_collected_tax_ccid	= ' || p_collected_tax_ccid,
                   'plsql');
       arp_standard.debug(  'p_collected_tax_concat_seg	= ' || p_collected_tax_concat_seg,
                   'plsql');
       arp_standard.debug(  'p_comments                  = ' || p_comments,
                   'plsql');
       arp_standard.debug(  'p_account_set_flag          = ' || p_account_set_flag,
                   'plsql');
       arp_standard.debug(  'p_ussgl_transaction_code    = ' ||
                      p_ussgl_transaction_code,
                   'plsql');
       arp_standard.debug(  'p_ussgl_trx_code_context    = ' ||
                      p_ussgl_trx_code_context,
                   'plsql');
       arp_standard.debug(  'p_attribute_category        = ' || p_attribute_category,
                   'plsql');
       arp_standard.debug(  'p_attribute1                = ' || p_attribute1,
                   'plsql');
       arp_standard.debug(  'p_attribute2                = ' || p_attribute2,
                   'plsql');
       arp_standard.debug(  'p_attribute3                = ' || p_attribute3,
                   'plsql');
       arp_standard.debug(  'p_attribute4                = ' || p_attribute4,
                   'plsql');
       arp_standard.debug(  'p_attribute5                = ' || p_attribute5,
                   'plsql');
       arp_standard.debug(  'p_attribute6                = ' || p_attribute6,
                   'plsql');
       arp_standard.debug(  'p_attribute7                = ' || p_attribute7,
                   'plsql');
       arp_standard.debug(  'p_attribute8                = ' || p_attribute8,
                   'plsql');
       arp_standard.debug(  'p_attribute9                = ' || p_attribute9,
                   'plsql');
       arp_standard.debug(  'p_attribute10               = ' || p_attribute10,
                   'plsql');
       arp_standard.debug(  'p_attribute11               = ' || p_attribute11,
                   'plsql');
       arp_standard.debug(  'p_attribute12               = ' || p_attribute12,
                   'plsql');
       arp_standard.debug(  'p_attribute13               = ' || p_attribute13,
                   'plsql');
       arp_standard.debug(  'p_attribute14               = ' || p_attribute14,
                   'plsql');
       arp_standard.debug(  'p_attribute15               = ' || p_attribute15,
                   'plsql');
    END IF;

    RAISE;

END insert_dist_cover;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    set_original_gl_date						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Resets original GL date to valid value from ar_revenue_assignments if  |
 |    a rule based invoice line to ensure the credit memo module will pick   |
 |    up the distribution when a credit memo is created.                     |
 |    Distributions on rule based invoice lines have been manually entered   |
 |    via the Distributions window in ARXTWMAI.                              |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_customer_trx_line_id                                 |
 |                    p_original_gl_date                                     |
 |              OUT:                                                         |
 |                    None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : Valid original GL date                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-DEC-02  Jon Beckett         Created for bug 2569911.               |
 |                                                                           |
 +===========================================================================*/

FUNCTION set_original_gl_date(
    p_customer_trx_id      IN ra_customer_trx.customer_trx_id%TYPE
   ,p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE
   ,p_original_gl_date     IN ra_cust_trx_line_gl_dist.gl_date%TYPE
   ,p_account_class        IN ra_cust_trx_line_gl_dist.account_class%TYPE)
RETURN DATE
IS
  CURSOR c_rule_based_inv IS
  SELECT ctl.accounting_rule_id, ctt.type
  FROM   ra_customer_trx_lines ctl,
         ra_cust_trx_types ctt,
         ra_customer_trx ct
  WHERE  ctl.customer_trx_id = ct.customer_trx_id
  AND    ct.cust_trx_type_id = ctt.cust_trx_type_id
  AND    ctl.customer_trx_line_id = p_customer_trx_line_id;

  CURSOR c_valid_rule_gl_date IS
  SELECT ra.gl_date
  FROM   ar_revenue_assignments ra,
         gl_sets_of_books sob,
         ar_system_parameters sp
  WHERE  ra.customer_trx_line_id = p_customer_trx_line_id
  AND    sob.set_of_books_id = sp.set_of_books_id
  AND    ra.period_set_name = sob.period_set_name
  AND    ra.account_class = 'REV'
  and    ROWNUM = 1;

  l_accounting_rule_id      ra_rules.rule_id%TYPE;
  l_trx_type                ra_cust_trx_types.type%TYPE;
  l_valid_orig_gl_date      DATE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_insert_dist_cover.set_original_gl_date()+');
  END IF;

  IF p_account_class <> 'REV'
  THEN
    RETURN p_original_gl_date;
  END IF;

  OPEN c_rule_based_inv;
  FETCH c_rule_based_inv INTO l_accounting_rule_id, l_trx_type;
  CLOSE c_rule_based_inv;

  IF l_trx_type = 'INV' AND l_accounting_rule_id IS NOT NULL
  THEN
    OPEN c_valid_rule_gl_date;
    FETCH c_valid_rule_gl_date INTO l_valid_orig_gl_date;
    CLOSE c_valid_rule_gl_date;
  ELSE
    l_valid_orig_gl_date := p_original_gl_date;
  END IF;
  RETURN l_valid_orig_gl_date;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_insert_dist_cover.set_original_gl_date()-',
                     'plsql');
  END IF;
EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION:  arp_process_dist.insert_dist_cover()'||
       sqlerrm, 'plsql');
    END IF;
    RETURN p_original_gl_date;
END set_original_gl_date;

  /*---------------------------------------------+
   |   Package initialization section.           |
   +---------------------------------------------*/

BEGIN

   pg_msg_level_debug := arp_global.MSG_LEVEL_DEBUG;

END ARP_INSERT_DIST_COVER;

/
