--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_CREDIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_CREDIT_UTIL" AS
/* $Header: ARTECMUB.pls 120.12.12010000.1 2008/07/24 16:55:42 appldev ship $ */

pg_set_of_books_id          ar_system_parameters.set_of_books_id%type;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_commitment_adjustments                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get the commitment adjustment amount for a child invoice  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_ct_id                                                 |
 |                   p_commit_ct_id                                          |
 |                                                                           |
 | RETURNS    : amount - NUMBER                                              |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |     18-JUN-01  Michael Raymond     1483656 - added new procedure
 |                                    called get_commitment_adjustments
 |                                    to retrv line, tax, and freight bal.
 +===========================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION get_commitment_adjustments(
  p_ct_id              IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id       IN ra_customer_trx.customer_trx_id%type) RETURN number
IS
  l_amount     number;
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_commitment_adjustments()+');
    END IF;

    SELECT sum(amount)
    INTO   l_amount
    FROM   ar_adjustments adj,
           ra_cust_trx_types commit_ctt,
           ra_customer_trx commit_trx
    WHERE  commit_ctt.cust_trx_type_id = commit_trx.cust_trx_type_id
    AND    commit_trx.customer_trx_id  = p_commit_ct_id
    AND    commit_ctt.type             = 'DEP'
    AND    adj.customer_trx_id         = p_ct_id
    AND    adj.adjustment_type         = 'C';

    return(l_amount);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_commitment_adjustments()-');
    END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_commitment_adjustments: ' || 'EXCEPTION : '||
                   'arp_process_credit_util.get_commitment_adjustments');
       arp_util.debug('get_commitment_adjustments: ' || 'p_ct_id          : '||p_ct_id);
       arp_util.debug('get_commitment_adjustments: ' || 'p_commit_ct_id   : '||p_commit_ct_id);
    END IF;
    RAISE;
END get_commitment_adjustments;

/*===========================================================================+
 | PROCEDURE                                                                  |
 |    get_commitment_adj_detail                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get the commitment adjustment amount (line, tax, and frt  |
 |     for a child invoice  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_ct_id                                                 |
 |                   p_commit_ct_id                                          |
 |                   p_amount
 |                   p_line_amount
 |                   p_tax_amount
 |                   p_freight_amount
 |
 | RETURNS    :                                               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     18-JUN-01  Michael Raymond     1483656 - added new procedure
 |                                    to retrieve commitment adjustments
 |                                    (line, tax, and freight)
 +===========================================================================*/

PROCEDURE get_commitment_adj_detail(
  p_ct_id              IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id       IN ra_customer_trx.customer_trx_id%type,
  p_amount             IN OUT NOCOPY number,
  p_line_amount        IN OUT NOCOPY number,
  p_tax_amount         IN OUT NOCOPY number,
  p_freight_amount     IN OUT NOCOPY number)
IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_commitment_adj_detail()+');
    END IF;

    SELECT sum(amount), sum(NVL(line_adjusted,0)),
           sum(NVL(tax_adjusted,0)), sum(NVL(freight_adjusted,0))
    INTO   p_amount,
           p_line_amount,
           p_tax_amount,
           p_freight_amount
    FROM   ar_adjustments adj,
           ra_cust_trx_types commit_ctt,
           ra_customer_trx commit_trx
    WHERE  commit_ctt.cust_trx_type_id = commit_trx.cust_trx_type_id
    AND    commit_trx.customer_trx_id  = p_commit_ct_id
    AND    commit_ctt.type             = 'DEP'
    AND    adj.customer_trx_id         = p_ct_id
    AND    adj.adjustment_type         = 'C';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_commitment_adj_detail()-');
    END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_commitment_adj_detail: ' || 'EXCEPTION : '||
                   'arp_process_credit_util.get_commitment_adj_detail()');
       arp_util.debug('get_commitment_adj_detail: ' || 'p_ct_id          : '||p_ct_id);
       arp_util.debug('get_commitment_adj_detail: ' || 'p_commit_ct_id   : '||p_commit_ct_id);
    END IF;
    RAISE;
END get_commitment_adj_detail;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_credited_trx_amounts                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get amounts for the credited transaction                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_ct_id                                                 |
 |                   p_commit_ct_id                                          |
 |              OUT:                                                         |
 |                   p_orig_line_amount                                      |
 |                   p_orig_tax_amount                                       |
 |                   p_orig_frt_amount                                       |
 |                   p_bal_line_amount                                       |
 |                   p_bal_tax_amount                                        |
 |                   p_bal_frt_amount                                        |
 |                   p_num_line_lines                                        |
 |                   p_num_tax_lines                                         |
 |                   p_num_frt_lines                                         |
 |                   p_num_installments                                      |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_credited_trx_amounts(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id          IN ra_customer_trx.customer_trx_id%type,
  p_orig_line_amount     OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_tax_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_frt_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_tot_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_line_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_tax_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_frt_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_tot_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_num_line_lines       OUT NOCOPY number,
  p_num_tax_lines        OUT NOCOPY number,
  p_num_frt_lines        OUT NOCOPY number,
  p_num_installments     OUT NOCOPY number)
IS
  l_commit_adj_amount    number;
  l_commit_line_amount   number;
  l_commit_tax_amount    number;
  l_commit_frt_amount    number;
  l_orig_line_amount     ra_customer_trx_lines.extended_amount%type;
  l_orig_tax_amount      ra_customer_trx_lines.extended_amount%type;
  l_orig_frt_amount      ra_customer_trx_lines.extended_amount%type;
  l_orig_chrg_amount     ra_customer_trx_lines.extended_amount%type;
  l_orig_tot_amount      ra_customer_trx_lines.extended_amount%type;
  l_bal_line_amount      ra_customer_trx_lines.extended_amount%type;
  l_bal_tax_amount       ra_customer_trx_lines.extended_amount%type;
  l_bal_frt_amount       ra_customer_trx_lines.extended_amount%type;
  l_bal_chrg_amount      ra_customer_trx_lines.extended_amount%type;
  l_bal_tot_amount       ra_customer_trx_lines.extended_amount%type;
  l_num_line_lines       number;
  l_num_tax_lines        number;
  l_num_frt_lines        number;
  l_num_installments     number;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_credited_trx_amounts()+');
    END IF;

   /*--------------------------------------------------------------------+
    | get count of installments and lines by type                        |
    +--------------------------------------------------------------------*/

    SELECT count(*)
    INTO   l_num_installments
    FROM   ar_payment_schedules ps
    WHERE  ps.customer_trx_id = p_ct_id;

    SELECT count(decode(ctl.line_type,
                        'LINE', 1,
                        'CHARGES', 1,
                        'CB', 1,
                        null)),
           count(decode(ctl.line_type,
                        'TAX', 1,
                        null)),
           count(decode(ctl.line_type,
                        'FREIGHT', 1,
                        null))
    INTO   l_num_line_lines,
           l_num_tax_lines,
           l_num_frt_lines
    FROM   ra_customer_trx_lines ctl
    WHERE  ctl.customer_trx_id = p_ct_id;

   /*--------------------------------------------------------------------+
    | get transaction summary balances                                   |
    +--------------------------------------------------------------------*/
    arp_trx_util.get_summary_trx_balances(
                          p_ct_id,
                          null,
                          l_orig_line_amount,
                          l_bal_line_amount,
                          l_orig_tax_amount,
                          l_bal_tax_amount,
                          l_orig_frt_amount,
                          l_bal_frt_amount,
                          l_orig_chrg_amount,
                          l_bal_chrg_amount,
                          l_orig_tot_amount,
                          l_bal_tot_amount);

    --
    -- get commitment adjustments if the credited transaction is a
    -- child of a deposit
    --
    -- 1483656 - replacd call to original function (returned only
    -- adj amount - with new call to procedure that returns
    --  adj, line, tax, and frt.

    IF (p_commit_ct_id IS NOT NULL)
    THEN

        get_commitment_adj_detail(p_ct_id, p_commit_ct_id,
                                   l_commit_adj_amount,
                                   l_commit_line_amount,
                                   l_commit_tax_amount,
                                   l_commit_frt_amount);
    END IF;

    p_orig_line_amount := nvl(l_orig_line_amount,0);
    p_orig_tax_amount  := l_orig_tax_amount;
    p_orig_frt_amount  := l_orig_frt_amount;
    p_orig_tot_amount  := l_orig_tot_amount;

    p_bal_line_amount  := nvl(l_bal_line_amount, 0) -
                          nvl(l_commit_line_amount, 0);
    p_bal_tax_amount   := nvl(l_bal_tax_amount, 0) -
                          nvl(l_commit_tax_amount, 0);
    p_bal_frt_amount   := nvl(l_bal_frt_amount, 0) -
                          nvl(l_commit_frt_amount, 0);
    p_bal_tot_amount   := nvl(l_bal_tot_amount, 0) -
                          nvl(l_commit_adj_amount, 0);

    p_num_line_lines   := l_num_line_lines;
    p_num_tax_lines    := l_num_tax_lines;
    p_num_frt_lines    := l_num_frt_lines;
    p_num_installments := l_num_installments;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_credited_trx_amounts()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_credited_trx_amounts: ' || 'EXCEPTION : '||
                   'arp_process_credit_util.get_credited_trx_amounts');
       arp_util.debug('get_credited_trx_amounts: ' || 'p_ct_id                      : '||p_ct_id);
       arp_util.debug('get_credited_trx_amounts: ' || 'p_commit_ct_id               : '||p_commit_ct_id);
    END IF;

    RAISE;
END get_credited_trx_amounts;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_credited_trx_details                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get details for the credited transaction                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_ct_id                                                 |
 |                   p_commit_ct_id                                          |
 |              OUT:                                                         |
 |                   p_orig_line_amount                                      |
 |                   p_orig_tax_amount                                       |
 |                   p_orig_frt_amount                                       |
 |                   p_bal_line_amount                                       |
 |                   p_bal_tax_amount                                        |
 |                   p_bal_frt_amount                                        |
 |                   p_num_line_lines                                        |
 |                   p_num_tax_lines                                         |
 |                   p_num_frt_lines                                         |
 |                   p_num_installments                                      |
 |                   p_payment_exist_flag                                    |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_credited_trx_details(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_commit_ct_id          IN ra_customer_trx.customer_trx_id%type,
  p_orig_line_amount     OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_tax_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_frt_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_orig_tot_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_line_amount      OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_tax_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_frt_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_bal_tot_amount       OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_num_line_lines       OUT NOCOPY number,
  p_num_tax_lines        OUT NOCOPY number,
  p_num_frt_lines        OUT NOCOPY number,
  p_num_installments     OUT NOCOPY number,
  p_payment_exist_flag  OUT NOCOPY varchar2)
IS
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_credited_trx_details()+');
    END IF;

    get_credited_trx_amounts(
         p_ct_id,
         p_commit_ct_id,
         p_orig_line_amount,
         p_orig_tax_amount,
         p_orig_frt_amount,
         p_orig_tot_amount,
         p_bal_line_amount,
         p_bal_tax_amount,
         p_bal_frt_amount,
         p_bal_tot_amount,
         p_num_line_lines,
         p_num_tax_lines,
         p_num_frt_lines,
         p_num_installments);

    --
    -- get payment flag
    --
    select decode(nvl(sum(ps.amount_applied), 0),
                  0, 'N',
                  'Y')
    into   p_payment_exist_flag
    from   ar_payment_schedules ps
    where  customer_trx_id = p_ct_id;


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_credited_trx_details()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_credited_trx_details: ' || 'EXCEPTION : '||
                   'arp_process_credit_util.get_credited_trx_details');
       arp_util.debug('get_credited_trx_details: ' || 'p_ct_id                      : '||p_ct_id);
       arp_util.debug('get_credited_trx_details: ' || 'p_commit_ct_id               : '||p_commit_ct_id);
    END IF;

    RAISE;

END get_credited_trx_details;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_credited_memo_amounts                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get amounts for the credited memo                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_trx_util.get_summary_trx_balances                                  |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_ct_id                                                 |
 |              OUT:                                                         |
 |                   p_cm_line_amount                                        |
 |                   p_cm_tax_amount                                         |
 |                   p_cm_frt_amount                                         |
 |                   p_num_line_lines                                        |
 |                   p_num_tax_lines                                         |
 |                   p_num_frt_lines                                         |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_credit_memo_amounts(
  p_ct_id                 IN ra_customer_trx.customer_trx_id%type,
  p_cm_line_amount        OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_cm_tax_amount         OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_cm_frt_amount         OUT NOCOPY ra_customer_trx_lines.extended_amount%type,
  p_num_line_lines        OUT NOCOPY number,
  p_num_tax_lines         OUT NOCOPY number,
  p_num_frt_lines         OUT NOCOPY number)
IS
  l_cm_line_amount        ra_customer_trx_lines.extended_amount%type;
  l_cm_tax_amount         ra_customer_trx_lines.extended_amount%type;
  l_cm_frt_amount         ra_customer_trx_lines.extended_amount%type;
  l_num_line_lines        number;
  l_num_tax_lines         number;
  l_num_frt_lines         number;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_credit_memo_amounts()+');
    END IF;

    SELECT sum(decode(ctl.line_type,
                      'LINE',    ctl.extended_amount,
                      'CB',      ctl.extended_amount,
                      'CHARGES', ctl.extended_amount,
                      null)),
           sum(decode(ctl.line_type,
                      'TAX', ctl.extended_amount,
                      null)),
           sum(decode(ctl.line_type,
                      'FREIGHT', ctl.extended_amount,
                      null)),
           count(decode(ctl.line_type,
                      'LINE', 1,
                      'CB', 1,
                      'CHARGES', 1,
                      null)),
           count(decode(ctl.line_type,
                      'TAX', 1,
                      null)),
           count(decode(ctl.line_type,
                      'FREIGHT', 1,
                      null))
    INTO   l_cm_line_amount,
           l_cm_tax_amount,
           l_cm_frt_amount,
           l_num_line_lines,
           l_num_tax_lines,
           l_num_frt_lines
    FROM   ra_customer_trx_lines ctl
    WHERE  ctl.customer_trx_id = p_ct_id;

    p_cm_line_amount := l_cm_line_amount;
    p_cm_tax_amount  := l_cm_tax_amount;
    p_cm_frt_amount  := l_cm_frt_amount;
    p_num_line_lines := l_num_line_lines;
    p_num_tax_lines  := l_num_tax_lines;
    p_num_frt_lines  := l_num_frt_lines;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_credit_memo_amounts()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : arp_process_credit_util.get_credit_memo_amounts');
       arp_util.debug('get_credit_memo_amounts: ' || 'p_ct_id                      : '||p_ct_id);
    END IF;

    RAISE;

END get_credit_memo_amounts;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_parent_site_use                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get site use of the parent customer                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_parent_customer_id                                    |
 |              OUT:                                                         |
 |                   p_parent_site_use_id                                    |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_parent_site_use(
  p_parent_customer_id       IN hz_cust_accounts.cust_account_id%type,
  p_parent_site_use_id      OUT NOCOPY hz_cust_site_uses.site_use_id%type)
IS
  l_parent_site_use_id   hz_cust_site_uses.site_use_id%type;
BEGIN

     SELECT
           decode(count(*),
                  0, null,
                  1, substrb(min(decode(nvl(site_uses.primary_flag,'N'),
                                     'Y','1',
                                     'N','2')||to_char(site_uses.site_use_id)),
                                2),
                  decode(substrb(min(decode(nvl(site_uses.primary_flag,'N'),
                                         'Y','1',
                                         'N','2')||to_char(site_uses.site_use_id)),
                                    1,1),
                  '1', substrb(min(decode(nvl(site_uses.primary_flag,'N'),
                                       'Y','1',
                                       'N','2')||to_char(site_uses.site_use_id)),
                                  2),
                  null))
     INTO l_parent_site_use_id
     FROM hz_cust_site_uses site_uses,
          hz_cust_acct_sites acct_site
     WHERE site_uses.site_use_code = 'BILL_TO'
     and   site_uses.cust_acct_site_id    = acct_site.cust_acct_site_id
     and   acct_site.cust_account_id = p_parent_customer_id;

     p_parent_site_use_id := l_parent_site_use_id;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : get_parent_site_use');
       arp_util.debug('get_parent_site_use: ' || 'p_parent_customer_id     : '||p_parent_customer_id);
    END IF;
    RAISE;
END get_parent_site_use;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_parent_customer_site                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get the parent customer and parent site use               |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_bill_to_customer_id                                   |
 |              OUT:                                                         |
 |                   p_parent_customer_id                                    |
 |                   p_parent_site_use_id                                    |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_parent_customer_site(
  p_bill_to_customer_id      IN hz_cust_accounts.cust_account_id%type,
  p_parent_customer_id      OUT NOCOPY hz_cust_accounts.cust_account_id%type,
  p_parent_site_use_id      OUT NOCOPY hz_cust_site_uses.site_use_id%type)
IS
  l_parent_customer_id   hz_cust_accounts.cust_account_id%type;
BEGIN

    BEGIN

        SELECT cr.cust_account_id
        INTO   l_parent_customer_id
        FROM   hz_cust_acct_relate cr
        WHERE  cr.related_cust_account_id = p_bill_to_customer_id
        AND    cr.status = 'A'
        AND    cr.bill_to_flag = 'Y'
        AND    nvl(cr.customer_reciprocal_flag,'N') = 'N';

        p_parent_customer_id := l_parent_customer_id;

    EXCEPTION

      WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
        l_parent_customer_id := null;
      WHEN OTHERS THEN
        RAISE;
    END;

    IF (l_parent_customer_id IS NOT NULL)
    THEN
        get_parent_site_use(l_parent_customer_id,
                            p_parent_site_use_id);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : get_parent_customer_site');
       arp_util.debug('get_parent_customer_site: ' || 'p_bill_to_customer_id      : '||p_bill_to_customer_id);
    END IF;
    RAISE;
END get_parent_customer_site;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_payment_method                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Function to check if the payment method is valid                       |
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
 |                   p_parent_customer_id                                    |
 |                   p_parent_site_use_id                                    |
 |                   p_currency_code                                         |
 |                   p_crtrx_receipt_method_id                               |
 |              OUT:                                                         |
 |                   p_payment_method_name                                   |
 |                   p_receipt_method_id                                     |
 |                   p_creation_method_code                                  |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : BOOLEAN   : TRUE if payment method is valid                  |
 |                          FALSE if invalid                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_payment_method(
   p_trx_date               IN
                                     ra_customer_trx.trx_date%type,
   p_customer_id            IN
                                     ra_customer_trx.customer_trx_id%type,
   p_site_use_id            IN
                                     hz_cust_site_uses.site_use_id%type,
   p_parent_customer_id     IN
                                     hz_cust_accounts.cust_account_id%type,
   p_parent_site_use_id     IN
                                     hz_cust_site_uses.site_use_id%type,
   p_currency_code          IN
                                     fnd_currencies.currency_code%type,
   p_crtrx_receipt_method_id IN
                                     ar_receipt_methods.receipt_method_id%type,
   p_payment_method_name   OUT NOCOPY
                                     ar_receipt_methods.name%type,
   p_receipt_method_id     OUT NOCOPY
                                     ar_receipt_methods.receipt_method_id%type,
   p_creation_method_code  OUT NOCOPY
                                   ar_receipt_classes.creation_method_code%type
                             ) RETURN BOOLEAN IS

   l_payment_method_name   ar_receipt_methods.name%type;
   l_receipt_method_id     ar_receipt_methods.receipt_method_id%type;
   l_creation_method_code  ar_receipt_classes.creation_method_code%type;

BEGIN

   SELECT    arm.name,
             arm.receipt_method_id,
             arc.creation_method_code,
             arm.name,
             arm.receipt_method_id,
             arc.creation_method_code
   INTO      l_payment_method_name,
             l_receipt_method_id,
             l_creation_method_code,
             p_payment_method_name,
             p_receipt_method_id,
             p_creation_method_code
   FROM      ar_receipt_methods         arm,
             ra_cust_receipt_methods    rcrm,
             ar_receipt_method_accounts arma,
             ce_bank_accounts     	cba,
             ce_bank_acct_uses          aba,
             ar_receipt_classes         arc,
	     ce_bank_branches_v         bp /*Bug3348454*/
   WHERE     arm.receipt_method_id = rcrm.receipt_method_id
   AND       arm.receipt_method_id = arma.receipt_method_id
   AND       arm.receipt_class_id  = arc.receipt_class_id
   AND       arma.remit_bank_acct_use_id  = aba.bank_acct_use_id
   AND       aba.bank_account_id = cba.bank_account_id
   /*Bug3348454*/
   AND	     cba.bank_branch_id = bp.branch_party_id
   AND       p_trx_date <= NVL(bp.end_date,p_trx_date)
   /*Bug3348454*/

   -- AND       aba.set_of_books_id = pg_set_of_books_id
   AND       arm.receipt_method_id = p_crtrx_receipt_method_id
   AND
            (
               (  rcrm.customer_id      = p_customer_id
                  AND
                  NVL(rcrm.site_use_id,
                      p_site_use_id)   = p_site_use_id
               )
               OR
               (  rcrm.customer_id = nvl(p_parent_customer_id,
                                         -88888)
                  AND
                  nvl(rcrm.site_use_id,
                      nvl(p_parent_site_use_id,
                          -88888)) = nvl(p_parent_site_use_id,
                                        -88888)
               )
            )
   AND       (
                 cba.currency_code    =
                             p_currency_code  OR
                 cba.receipt_multi_currency_flag = 'Y'
             )
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
   AND      rownum = 1;

   return(TRUE);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('check_payment_method: ' || 'return value: FALSE');
    END IF;
    RETURN(FALSE);

  WHEN OTHERS THEN
    RAISE;

END check_payment_method;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_bank_account                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Function to check if a bank account is valid                           |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_trx_date                                              |
 |                   p_currency_code                                         |
 |                   p_bill_to_customer_id                                   |
 |                   p_bill_to_site_use_id                                   |
 |                   p_parent_customer_id                                    |
 |                   p_parent_site_use_id                                    |
 |                   p_crtrx_cust_bank_account_id                            |
 |              OUT:                                                         |
 |                   p_cust_bank_account_id                                  |
 |                   p_paying_customer_id                                    |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : BOOLEAN   : TRUE if bank account   is valid                  |
 |                          FALSE if invalid                                 |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_bank_account(
  p_trx_date                     IN
                          ra_customer_trx.trx_date%type,
  p_currency_code                IN
                          fnd_currencies.currency_code%type,
  p_bill_to_customer_id          IN
                          hz_cust_accounts.cust_account_id%type,
  p_bill_to_site_use_id          IN
                          hz_cust_site_uses.site_use_id%type,
  p_parent_customer_id           IN
                          hz_cust_accounts.cust_account_id%type,
  p_parent_site_use_id           IN
                          hz_cust_site_uses.site_use_id%type,
  p_crtrx_cust_bank_account_id   IN
                          ce_bank_accounts.bank_account_id%type,
  p_cust_bank_account_id         OUT NOCOPY
                          ce_bank_accounts.bank_account_id%type,
  p_paying_customer_id           OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type)
RETURN BOOLEAN IS
  l_cust_bank_account_id   ce_bank_accounts.bank_account_id%type;
  l_paying_customer_id     hz_cust_accounts.cust_account_id%type;
  l_account_valid          boolean := FALSE;
BEGIN
/* BICHATTE removed the validation for bank account
   PAYMENT UPTAKE */
 RETURN(TRUE);
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    check_cm_trxtype                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Function to check whether the cm transaction types has the open        |
 |    receivable flag and post to gl are same as their related invoice.      |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_inv_trx_type_id                                       |
 |                   p_inv_open_rec_flag                                     |
 |                   p_cm_trx_type_id                                        |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : BOOLEAN   :  if same flags then TRUE else FALSE              |
 |                                                                           |
 | NOTES                                                                     |
 |    Bug-3205760 - 3547652                                                  |
 | MODIFICATION HISTORY                                                      |
 |     17-MAY-2004  Surendra Rajan      Created                              |
 |                                                                           |
 +===========================================================================*/

FUNCTION check_cm_trxtype(
  p_inv_trx_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_inv_open_rec_flag           IN
                          ra_cust_trx_types.accounting_affect_flag%type,
  p_cm_trx_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type
 )
RETURN BOOLEAN  IS
  l_dummy        char := 'N';
BEGIN
     IF P_INV_TRX_TYPE_ID  IS NOT NULL  Then

          Select 'Y' Into l_dummy
          from ra_cust_trx_types cmctt
          where cmctt.cust_trx_type_id          = p_cm_trx_type_id
                  and
                cmctt.accounting_affect_flag    = nvl(p_inv_open_rec_flag,cmctt.accounting_affect_flag)    and
                cmctt.post_to_gl                = (select post_to_gl from ra_cust_trx_types invctt
                                                  where invctt.cust_trx_type_id = p_inv_trx_type_id);
     End If;
     Return(TRUE);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(FALSE);
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : check_cm_trxtype');
    END IF;
    RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_cm_defaults                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure to get the defaults for a CM                                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                   None                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Subash Chadalavada  Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_cm_header_defaults(
  p_trx_date                     IN
                          ra_customer_trx.trx_date%type,
  p_crtrx_ct_id                  IN
                          ra_customer_trx.customer_trx_id%type,
  p_ct_id                        IN
                          ra_customer_trx.customer_trx_id%type,
  p_bs_id                        IN
                          ra_batch_sources.batch_source_id%type,
  p_gl_date                      IN
                          ra_cust_trx_line_gl_dist.gl_date%type,
  p_currency_code                IN
                          fnd_currencies.currency_code%type,
  p_cust_trx_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_ship_to_customer_id          IN
                          hz_cust_accounts.cust_account_id%type,
  p_ship_to_site_use_id          IN
                          hz_cust_site_uses.site_use_id%type,
  p_ship_to_contact_id           IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_bill_to_customer_id          IN
                          hz_cust_accounts.cust_account_id%type,
  p_bill_to_site_use_id          IN
                          hz_cust_site_uses.site_use_id%type,
  p_bill_to_contact_id           IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_primary_salesrep_id          IN
                          ra_salesreps.salesrep_id%type,
  p_receipt_method_id            IN
                          ar_receipt_methods.receipt_method_id%type,
  p_customer_bank_account_id     IN
                          ce_bank_accounts.bank_account_id%type,
  p_paying_customer_id           IN
                          hz_cust_accounts.cust_account_id%type,
  p_paying_site_use_id           IN
                          hz_cust_site_uses.site_use_id%type,
  p_ship_via                     IN
                          ra_customer_trx.ship_via%type,
  p_fob_point                    IN
                          ra_customer_trx.fob_point%type,
  p_invoicing_rule_id            IN
                          ra_customer_trx.invoicing_rule_id%type,
  p_rev_recog_run_flag           IN
                          varchar2,
  p_complete_flag                IN
                          ra_customer_trx.complete_flag%type,
  p_salesrep_required_flag       IN
                          ar_system_parameters.salesrep_required_flag%type,
--
  p_crtrx_bs_id                  IN
                          ra_batch_sources.batch_source_id%type,
  p_crtrx_cm_bs_id               IN
                          ra_batch_sources.batch_source_id%type,
  p_batch_bs_id                  IN
                          ra_batch_sources.batch_source_id%type,
  p_profile_bs_id                IN
                          ra_batch_sources.batch_source_id%type,
  p_crtrx_type_id                IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_crtrx_cm_type_id             IN
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_crtrx_gl_date                IN
                          ra_cust_trx_line_gl_dist.gl_date%type,
  p_batch_gl_date                IN
                          ra_batches.gl_date%type,
--
  p_crtrx_ship_to_customer_id    IN
                          hz_cust_accounts.cust_account_id%type,
  p_crtrx_ship_to_site_use_id    IN
                          hz_cust_site_uses.site_use_id%type,
  p_crtrx_ship_to_contact_id     IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_crtrx_bill_to_customer_id    IN
                          hz_cust_accounts.cust_account_id%type,
  p_crtrx_bill_to_site_use_id    IN
                          hz_cust_site_uses.site_use_id%type,
  p_crtrx_bill_to_contact_id     IN
                          hz_cust_account_roles.cust_account_role_id%type,
  p_crtrx_primary_salesrep_id    IN
                          ra_salesreps.salesrep_id%type,
  p_crtrx_open_rec_flag          IN
                          ra_cust_trx_types.accounting_affect_flag%type,
--
  p_crtrx_receipt_method_id      IN
                          ar_receipt_methods.receipt_method_id%type,
  p_crtrx_cust_bank_account_id   IN
                          ce_bank_accounts.bank_account_id%type,
  p_crtrx_ship_via               IN
                          ra_customer_trx.ship_via%type,
  p_crtrx_ship_date_actual       IN
                          ra_customer_trx.ship_date_actual%type,
  p_crtrx_waybill_number         IN
                          ra_customer_trx.waybill_number%type,
  p_crtrx_fob_point              IN
                          ra_customer_trx.fob_point%type,
--
  p_default_bs_id                OUT NOCOPY
                          ra_batch_sources.batch_source_id%type,
  p_default_bs_name              OUT NOCOPY
                          ra_batch_sources.name%type,
  p_auto_trx_numbering_flag      OUT NOCOPY
                          ra_batch_sources.auto_trx_numbering_flag%type,
  p_bs_type                      OUT NOCOPY
                          ra_batch_sources.batch_source_type%type,
  p_copy_doc_number_flag	 OUT NOCOPY
			  ra_batch_sources.copy_doc_number_flag%type,
  p_bs_default_cust_trx_type_id  OUT NOCOPY
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_default_cust_trx_type_id     OUT NOCOPY
                          ra_cust_trx_types.cust_trx_type_id%type,
  p_default_type_name            OUT NOCOPY
                          ra_cust_trx_types.name%type,
  p_open_receivable_flag         OUT NOCOPY
                          ra_cust_trx_types.accounting_affect_flag%type,
  p_post_to_gl_flag              OUT NOCOPY
                          ra_cust_trx_types.post_to_gl%type,
  p_allow_freight_flag           OUT NOCOPY
                          ra_cust_trx_types.allow_freight_flag%type,
  p_creation_sign                OUT NOCOPY
                          ra_cust_trx_types.creation_sign%type,
  p_allow_overapplication_flag   OUT NOCOPY
                          ra_cust_trx_types.allow_overapplication_flag%type,
  p_natural_app_only_flag        OUT NOCOPY
                          ra_cust_trx_types.natural_application_only_flag%type,
  p_tax_calculation_flag         OUT NOCOPY
                          ra_cust_trx_types.tax_calculation_flag%type,
  p_default_printing_option      OUT NOCOPY
                          ra_customer_trx.printing_option%type,
--
  p_default_gl_date              OUT NOCOPY
                          ra_cust_trx_line_gl_dist.gl_date%type,
  p_default_ship_to_customer_id  OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type,
  p_default_ship_to_site_use_id  OUT NOCOPY
                          hz_cust_site_uses.site_use_id%type,
  p_default_ship_to_contact_id   OUT NOCOPY
                          hz_cust_account_roles.cust_account_role_id%type,
  p_default_bill_to_customer_id  OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type,
  p_default_bill_to_site_use_id  OUT NOCOPY
                          hz_cust_site_uses.site_use_id%type,
  p_default_bill_to_contact_id   OUT NOCOPY
                          hz_cust_account_roles.cust_account_role_id%type,
  p_default_primary_salesrep_id  OUT NOCOPY
                          ra_salesreps.salesrep_id%type,
  p_default_receipt_method_id    OUT NOCOPY
                          ar_receipt_methods.receipt_method_id%type,
  p_default_cust_bank_account_id OUT NOCOPY
                          ce_bank_accounts.bank_account_id%type,
  p_default_paying_customer_id   OUT NOCOPY
                          hz_cust_accounts.cust_account_id%type,
  p_default_paying_site_use_id   OUT NOCOPY
                          hz_cust_site_uses.site_use_id%type,
  p_default_ship_via             OUT NOCOPY
                          ra_customer_trx.ship_via%type,
  p_default_ship_date_actual     OUT NOCOPY
                          ra_customer_trx.ship_date_actual%type,
  p_default_waybill_number       OUT NOCOPY
                          ra_customer_trx.waybill_number%type,
  p_default_fob_point            OUT NOCOPY
                          ra_customer_trx.fob_point%type
)
IS
   l_bs_id                         ra_batch_sources.batch_source_id%type;
   l_default_bs_name               ra_batch_sources.name%type;
   l_auto_trx_numbering_flag  ra_batch_sources.auto_trx_numbering_flag%type;
   l_bs_type                       ra_batch_sources.batch_source_type%type;
   l_copy_doc_number_flag	   ra_batch_sources.copy_doc_number_flag%type;
   l_bs_default_cust_trx_type_id   ra_cust_trx_types.cust_trx_type_id%type;
   l_default_cust_trx_type_id      ra_cust_trx_types.cust_trx_type_id%type;
   l_default_status_code           ar_lookups.lookup_code%type;
   l_default_status                ar_lookups.meaning%type;
   l_default_printing_option_code  ar_lookups.lookup_code%type;
   l_default_printing_option       ar_lookups.meaning%type;
   l_default_term_id               ra_terms.term_id%type;
   l_default_term_name             ra_terms.name%type;
   l_bill_to_customer_id           hz_cust_accounts.cust_account_id%type;
   l_bill_to_site_use_id           hz_cust_site_uses.site_use_id%type;
   l_ship_to_site_use_id           hz_cust_site_uses.site_use_id%type; --4766915
   l_ship_to_contact_id            hz_cust_account_roles.cust_account_role_id%type;
   l_primary_salesrep_id           ra_salesreps.salesrep_id%type;
   l_number_of_due_dates           number;
   l_term_due_date                 date;
   l_default_class                 ra_cust_trx_types.type%type;
   l_post_to_gl_flag               ra_cust_trx_types.post_to_gl%type;
   l_allow_not_open_flag           varchar2(1);
   l_default_gl_date               ra_cust_trx_line_gl_dist.gl_date%type;
   l_defaulting_rule_used          varchar2(128);
   l_error_message                 varchar2(128);

   l_paying_customer_id            hz_cust_accounts.cust_account_id%type;
   l_parent_customer_id            hz_cust_accounts.cust_account_id%type;
   l_paying_site_use_id            hz_cust_site_uses.site_use_id%type;
   l_parent_site_use_id            hz_cust_site_uses.site_use_id%type;

   l_receipt_method_id             ar_receipt_methods.receipt_method_id%type;
   l_payment_method_name           ar_receipt_methods.name%type;
   l_creation_method_code          ar_receipt_classes.creation_method_code%type;
   l_cust_bank_account_id          ce_bank_accounts.bank_account_id%type;
   l_bank_account_num              ce_bank_accounts.bank_account_num%type;
   l_bank_name                     ce_bank_branches_v.bank_name%type;
   l_bank_branch_name              ce_bank_branches_v.bank_branch_name%type;
   l_bank_branch_id                ce_bank_branches_v.branch_party_id%TYPE;

   -- 7/18/98: gjayanth: ar_receipt_methods.payment_type_code is an
   -- additional parameter to get_bank_defaults().
   --
   l_payment_type_code ar_receipt_methods.payment_type_code%type := NULL;

   -- Added for bug # 2712726
   -- ORASHID
   --
   l_nocopy_cust_bank_account_id  ce_bank_accounts.bank_account_id%type;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_cm_header_defaults()+');
    END IF;

    --
    -- first try out NOCOPY the credit memo batch source corresponding to
    -- the credited transaction's batch source
    --
    IF ( p_bs_id  IS NOT NULL )
    THEN
        arp_trx_defaults_2.get_source_default(
                           p_bs_id,
                           'CM',
                           p_trx_date,
                           null,
                           l_bs_id,
                           p_default_bs_name,
                           p_auto_trx_numbering_flag,
                           p_bs_type,
			   p_copy_doc_number_flag,
                           l_bs_default_cust_trx_type_id
                          );
    END IF;

    --
    -- try credit memo batch source corresponding to the credited
    -- transaction's batch source
    --
    IF ( l_bs_id  IS NULL
         AND
         p_crtrx_cm_bs_id IS NOT NULL )
    THEN
        arp_trx_defaults_2.get_source_default(
                           p_crtrx_cm_bs_id,
                           'CM',
                           p_trx_date,
                           null,
                           l_bs_id,
                           p_default_bs_name,
                           p_auto_trx_numbering_flag,
                           p_bs_type,
		           p_copy_doc_number_flag,
                           l_bs_default_cust_trx_type_id
                          );
    END IF;

    --
    -- try credited transaction's batch source
    --
    IF ( l_bs_id  IS NULL
         AND
         p_crtrx_bs_id IS NOT NULL )
    THEN
        arp_trx_defaults_2.get_source_default(
                           p_crtrx_bs_id,
                           'CM',
                           p_trx_date,
                           null,
                           l_bs_id,
                           p_default_bs_name,
                           p_auto_trx_numbering_flag,
                           p_bs_type,
			   p_copy_doc_number_flag,
                           l_bs_default_cust_trx_type_id
                          );
    END IF;

    --
    -- try batch source for the batch
    --
    IF ( l_bs_id  IS NULL
         AND
         p_batch_bs_id IS NOT NULL )
    THEN
        arp_trx_defaults_2.get_source_default(
                           p_batch_bs_id,
                           'CM',
                           p_trx_date,
                           null,
                           l_bs_id,
                           p_default_bs_name,
                           p_auto_trx_numbering_flag,
                           p_bs_type,
			   p_copy_doc_number_flag,
                           l_bs_default_cust_trx_type_id
                          );
    END IF;

    -- try profile

    IF ( l_bs_id  IS NULL
         AND
         p_profile_bs_id IS NOT NULL )
    THEN
        arp_trx_defaults_2.get_source_default(
                           p_profile_bs_id,
                           'CM',
                           p_trx_date,
                           null,
                           l_bs_id,
                           p_default_bs_name,
                           p_auto_trx_numbering_flag,
                           p_bs_type,
			   p_copy_doc_number_flag,
                           l_bs_default_cust_trx_type_id
                          );
    END IF;

    IF ( l_bs_id IS NULL )
    THEN return;
    ELSE
        p_default_bs_id := l_bs_id;
        p_bs_default_cust_trx_type_id := l_bs_default_cust_trx_type_id;

        IF ( p_cust_trx_type_id IS NOT NULL )
        THEN
            arp_trx_defaults_2.get_type_defaults(
                                   p_cust_trx_type_id,
                                   p_trx_date,
                                   'CM',
                                   null,
                                   p_invoicing_rule_id,
                                   p_rev_recog_run_flag,
                                   p_complete_flag,
                                   p_crtrx_open_rec_flag,
                                   p_ct_id,
                                   l_default_cust_trx_type_id,
                                   p_default_type_name,
                                   l_default_class,
                                   p_open_receivable_flag,
                                   l_post_to_gl_flag,
                                   p_allow_freight_flag,
                                   p_creation_sign,
                                   p_allow_overapplication_flag,
                                   p_natural_app_only_flag,
                                   p_tax_calculation_flag,
                                   l_default_status_code,
                                   l_default_status,
                                   l_default_printing_option_code,
                                   l_default_printing_option,
                                   l_default_term_id,
                                   l_default_term_name,
                                   l_number_of_due_dates,
                                   l_term_due_date);
         END IF;

         IF ( l_default_cust_trx_type_id IS NULL
              AND
              p_crtrx_cm_type_id IS NOT NULL)
         THEN
         /* Bug-3205760 */
            IF (check_cm_trxtype(
                                 p_crtrx_type_id,    -- Invoice trx type
                                 p_crtrx_open_rec_flag,  -- Invoice flag
                                 p_crtrx_cm_type_id      -- cm trx type
                                )
               )   Then
            arp_trx_defaults_2.get_type_defaults(
                                   p_crtrx_cm_type_id,
                                   p_trx_date,
                                   'CM',
                                   null,
                                   p_invoicing_rule_id,
                                   p_rev_recog_run_flag,
                                   p_complete_flag,
                                   p_crtrx_open_rec_flag,
                                   p_ct_id,
                                   l_default_cust_trx_type_id,
                                   p_default_type_name,
                                   l_default_class,
                                   p_open_receivable_flag,
                                   l_post_to_gl_flag,
                                   p_allow_freight_flag,
                                   p_creation_sign,
                                   p_allow_overapplication_flag,
                                   p_natural_app_only_flag,
                                   p_tax_calculation_flag,
                                   l_default_status_code,
                                   l_default_status,
                                   l_default_printing_option_code,
                                   l_default_printing_option,
                                   l_default_term_id,
                                   l_default_term_name,
                                   l_number_of_due_dates,
                                   l_term_due_date);
            END IF;
         END IF;

         IF ( l_default_cust_trx_type_id IS NULL
              AND
              l_bs_default_cust_trx_type_id IS NOT NULL)
         THEN
         /* Bug-3205760 */
            IF (check_cm_trxtype(
                                 p_crtrx_type_id,    -- Invoice trx type
                                 p_crtrx_open_rec_flag,  -- Invoice flag
                                 l_bs_default_cust_trx_type_id      -- cm trx type
                                )
               )   Then
             arp_trx_defaults_2.get_type_defaults(
                                   l_bs_default_cust_trx_type_id,
                                   p_trx_date,
                                   'CM',
                                   null,
                                   p_invoicing_rule_id,
                                   p_rev_recog_run_flag,
                                   p_complete_flag,
                                   p_crtrx_open_rec_flag,
                                   p_ct_id,
                                   l_default_cust_trx_type_id,
                                   p_default_type_name,
                                   l_default_class,
                                   p_open_receivable_flag,
                                   l_post_to_gl_flag,
                                   p_allow_freight_flag,
                                   p_creation_sign,
                                   p_allow_overapplication_flag,
                                   p_natural_app_only_flag,
                                   p_tax_calculation_flag,
                                   l_default_status_code,
                                   l_default_status,
                                   l_default_printing_option_code,
                                   l_default_printing_option,
                                   l_default_term_id,
                                   l_default_term_name,
                                   l_number_of_due_dates,
                                   l_term_due_date);
             END IF;
         END IF;

         IF (l_default_cust_trx_type_id IS NOT NULL)
         THEN
            p_default_cust_trx_type_id := l_default_cust_trx_type_id;
            p_post_to_gl_flag          := l_post_to_gl_flag;
            p_default_printing_option  := l_default_printing_option_code;
         END IF;

    END IF;

    IF (l_post_to_gl_flag = 'Y')
    THEN
        IF   (p_invoicing_rule_id = -3)
        THEN  l_allow_not_open_flag := 'Y';
        ELSE  l_allow_not_open_flag := 'N';
        END IF;

        /* Bug 1882597
           The fourth parameter to the function call is changed to NULL
           from p_trx_date */
        IF (  arp_util.validate_and_default_gl_date(
                                       p_gl_date,
                                       p_trx_date,
                                       p_crtrx_gl_date,
                                       NULL,
                                       NULL,
                                       p_trx_date,
                                       p_crtrx_gl_date,
                                       p_batch_gl_date,
                                       l_allow_not_open_flag,
                                       TO_CHAR(p_invoicing_rule_id),
                  arp_trx_global.system_info.system_parameters.set_of_books_id,
                                       222,
                                       l_default_gl_date,
                                       l_defaulting_rule_used,
                                       l_error_message
                                     ) = FALSE )
        THEN
            fnd_message.set_name('AR', 'GENERIC_MESSAGE');
            fnd_message.set_token('GENERIC_TEXT',
                                  l_error_message);
            app_exception.raise_exception;

        ELSE

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('get_cm_header_defaults: ' || 'default GL Date: ' ||
                           to_char(l_default_gl_date) ||
                           '  Rule: ' || l_defaulting_rule_used);
            END IF;

            IF (l_default_gl_date IS NOT NULL)
            THEN
                p_default_gl_date := l_default_gl_date;
            END IF;
        END IF;

    END IF;

    IF (p_crtrx_ship_to_customer_id IS NOT NULL
        AND
        p_ship_to_customer_id IS NULL )
    THEN
        p_default_ship_to_customer_id := p_crtrx_ship_to_customer_id;
        p_default_ship_to_site_use_id := p_crtrx_ship_to_site_use_id;
        p_default_ship_to_contact_id  := p_crtrx_ship_to_contact_id;
	--4766915
        l_ship_to_site_use_id 	      := p_crtrx_ship_to_site_use_id;

        l_ship_to_contact_id  := p_crtrx_ship_to_contact_id;
    ELSE
        l_ship_to_contact_id := p_ship_to_contact_id;
	--4766915
        l_ship_to_site_use_id := p_ship_to_site_use_id;
    END IF;


    IF (p_crtrx_bill_to_customer_id IS NOT NULL
        AND
        p_bill_to_customer_id IS NULL )
    THEN
        p_default_bill_to_customer_id := p_crtrx_bill_to_customer_id;
        l_bill_to_customer_id := p_crtrx_bill_to_customer_id;
        p_default_bill_to_site_use_id := p_crtrx_bill_to_site_use_id;
        l_bill_to_site_use_id := p_crtrx_bill_to_site_use_id;

        BEGIN
            -- Bug 1883538:  replaced references of current role state with
            --               status column
            SELECT distinct acct_role.cust_account_role_id
            INTO   p_default_bill_to_contact_id
            FROM   hz_cust_account_roles acct_role,
                   hz_cust_site_uses site_uses
            WHERE  site_uses.site_use_id = l_bill_to_site_use_id
            AND    acct_role.cust_account_id  = l_bill_to_customer_id
            AND    nvl(acct_role.cust_acct_site_id,site_uses.cust_acct_site_id)
                          = site_uses.cust_acct_site_id
            AND    ( acct_role.cust_account_role_id = p_crtrx_bill_to_contact_id
                     OR
                     nvl(acct_role.status,'I') = 'A'
                   )
            AND    acct_role.cust_account_role_id =
                                  nvl(p_crtrx_bill_to_contact_id,
                                      l_ship_to_contact_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            null;
          WHEN OTHERS THEN
            RAISE;
        END;
    ELSE
        l_bill_to_customer_id := p_bill_to_customer_id;
        l_bill_to_site_use_id := p_bill_to_site_use_id;
    END IF;


   --Bug 4766915
    -- default to the salesrep id of the credited transaction
    -- Otherwise pick the sales person from the bill-to on the invoice.
    -- If not available, we pick it from the ship-to on the invoice.
    -- If neither of these are avilable, we do not default any sales person
    -- and we go to No Sales Credit.


    IF (p_crtrx_primary_salesrep_id IS NOT NULL)
    THEN

        IF ( p_primary_salesrep_id IS NULL)
        THEN
            --
            -- set to the primary salesrep id of the credited trx
            --
            p_default_primary_salesrep_id := p_crtrx_primary_salesrep_id;
            l_primary_salesrep_id := p_crtrx_primary_salesrep_id;
        ELSE
            l_primary_salesrep_id := p_primary_salesrep_id;
        END IF;

    ELSIF (l_bill_to_site_use_id IS NOT NULL
           AND
           l_primary_salesrep_id IS NULL )
    THEN
        BEGIN
            /* modified for tca uptake */
            SELECT s.salesrep_id
            INTO   l_primary_salesrep_id
            FROM   ra_salesreps s,
                   hz_cust_site_uses site_uses
            WHERE s.salesrep_id = site_uses.primary_salesrep_id
            AND   site_uses.site_use_id  = l_bill_to_site_use_id
            AND  p_trx_date BETWEEN nvl(start_date_active, p_trx_date)
                                AND nvl(end_date_active, p_trx_date);

            p_default_primary_salesrep_id := l_primary_salesrep_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            null;
          WHEN OTHERS THEN
            RAISE;
        END;
    END IF;

     IF (l_ship_to_site_use_id IS NOT NULL
         AND
         l_primary_salesrep_id IS NULL )
    THEN
        BEGIN
            /* modified for tca uptake */
            SELECT s.salesrep_id
            INTO   l_primary_salesrep_id
            FROM   ra_salesreps s,
                   hz_cust_site_uses site_uses
            WHERE s.salesrep_id = site_uses.primary_salesrep_id
            AND   site_uses.site_use_id  = l_ship_to_site_use_id
            AND  p_trx_date BETWEEN nvl(start_date_active, p_trx_date)
                                AND nvl(end_date_active, p_trx_date);

            p_default_primary_salesrep_id := l_primary_salesrep_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            null;
          WHEN OTHERS THEN
            RAISE;
        END;
    END IF;


    IF (p_salesrep_required_flag = 'Y'
        AND
        l_primary_salesrep_id IS NULL
        AND
        p_primary_salesrep_id IS NULL )
    THEN
        p_default_primary_salesrep_id := -3;  -- No Sales Credit
    END IF;

    get_parent_customer_site(l_bill_to_customer_id,
                             l_parent_customer_id,
                             l_parent_site_use_id);



    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_cm_header_defaults: ' || 'bill_to_customer_id : '||l_bill_to_customer_id);
       arp_util.debug('get_cm_header_defaults: ' || 'parent_customer_id  : '||l_parent_customer_id);
       arp_util.debug('get_cm_header_defaults: ' || 'parent_site_use_id  : '||l_parent_site_use_id);
       arp_util.debug('get_cm_header_defaults: ' || 'receipt_method_id   : '||p_receipt_method_id);
    END IF;

    --
    -- check if the receipt method is valid
    --
    IF (p_receipt_method_id IS NOT NULL)
    THEN
        IF (check_payment_method(
                               p_trx_date,
                               l_bill_to_customer_id,
                               l_bill_to_site_use_id,
                               l_parent_customer_id,
                               l_parent_site_use_id,
                               p_currency_code,
                               p_receipt_method_id,
                               l_payment_method_name,
                               l_receipt_method_id,
                               l_creation_method_code
                             ))
         THEN
             l_receipt_method_id := p_receipt_method_id;
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_util.debug('get_cm_header_defaults: ' || 'Receipt method is valid'||p_receipt_method_id);
             END IF;
         ELSE
             l_receipt_method_id := null;
         END IF;
    ELSE
        l_receipt_method_id := null;
    END IF;

    --
    -- default the receipt method
    --    credited transaction
    --    Primary payment method of the parent site use
    --    Primary payment method of the parent customer
    --    Primary payment method of the bill to site use
    --    Primary payment method of the bill to customer
    --

    IF (l_receipt_method_id IS NULL)
    THEN
        IF (check_payment_method(
                               p_trx_date,
                               l_bill_to_customer_id,
                               l_bill_to_site_use_id,
                               l_parent_customer_id,
                               l_parent_site_use_id,
                               p_currency_code,
                               p_crtrx_receipt_method_id,
                               l_payment_method_name,
                               l_receipt_method_id,
                               l_creation_method_code
                             ))
        THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('get_cm_header_defaults: ' || 'Credited Trx receipt method is valid : '||
                            p_crtrx_receipt_method_id);
            END IF;
        ELSE
            arp_trx_defaults_3.get_payment_method_default(
                               p_trx_date,
                               p_currency_code,
                               l_parent_customer_id,
                               l_parent_site_use_id,
                               l_bill_to_customer_id,
                               l_bill_to_site_use_id,
                               l_payment_method_name,
                               l_receipt_method_id,
                               l_creation_method_code);
        END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_cm_header_defaults: ' || 'creation method is : '||l_creation_method_code);
    END IF;
    IF (l_creation_method_code = 'MANUAL' )
    THEN
        p_default_cust_bank_account_id := null;
        p_default_paying_customer_id   := null;
        p_default_paying_site_use_id   := null;
    ELSIF (l_creation_method_code = 'AUTOMATIC' )
    THEN
        IF (p_customer_bank_account_id IS NOT NULL)
        THEN

            IF (check_bank_account(
                               p_trx_date,
                               p_currency_code,
                               l_bill_to_customer_id,
                               l_bill_to_site_use_id,
                               l_parent_customer_id,
                               l_parent_site_use_id,
                               p_customer_bank_account_id,
                               l_cust_bank_account_id,
                               l_paying_customer_id))
            THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('get_cm_header_defaults: ' || 'Bank account is valid : '||
                               p_customer_bank_account_id);
                END IF;
            ELSE
                l_cust_bank_account_id := null;
            END IF;
        END IF;

        IF (l_cust_bank_account_id IS NULL
            AND
            p_crtrx_cust_bank_account_id IS NOT NULL)
        THEN
            IF (check_bank_account(
                               p_trx_date,
                               p_currency_code,
                               l_bill_to_customer_id,
                               l_bill_to_site_use_id,
                               l_parent_customer_id,
                               l_parent_site_use_id,
                               p_crtrx_cust_bank_account_id,
                               l_cust_bank_account_id,
                               l_paying_customer_id))
            THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_util.debug('get_cm_header_defaults: ' || 'Credited Trx bank account is valid : '||
                               p_crtrx_cust_bank_account_id);
                END IF;
            ELSE
                l_cust_bank_account_id := null;
            END IF;
        END IF;

        IF (l_cust_bank_account_id IS NULL)
        THEN
            arp_trx_defaults_3.get_bank_defaults(
                                 p_trx_date,
                                 p_currency_code,
                                 l_parent_customer_id,
                                 l_parent_site_use_id,
                                 l_bill_to_customer_id,
                                 l_bill_to_site_use_id,
				 l_payment_type_code,
                                 l_cust_bank_account_id,
                                 l_bank_account_num,
                                 l_bank_name,
                                 l_bank_branch_name,
                                 l_bank_branch_id);

            -- Modified for bug # 2712726
            -- ORASHID
            --
            l_nocopy_cust_bank_account_id := l_cust_bank_account_id;

            IF (l_cust_bank_account_id IS NOT NULL
                AND

                check_bank_account(
                               p_trx_date,
                               p_currency_code,
                               l_bill_to_customer_id,
                               l_bill_to_site_use_id,
                               l_parent_customer_id,
                               l_parent_site_use_id,
                               l_nocopy_cust_bank_account_id,
                               l_cust_bank_account_id,
                               l_paying_customer_id))
            THEN
                null;
            END IF;
        END IF;

        p_default_paying_customer_id := l_paying_customer_id;

        IF (l_bill_to_customer_id = l_paying_customer_id)
        THEN
            p_default_paying_site_use_id := l_bill_to_site_use_id;
        ELSIF (l_parent_customer_id = l_paying_customer_id)
        THEN
            p_default_paying_site_use_id := l_parent_site_use_id;
        END IF;

    END IF;


    p_default_receipt_method_id    := l_receipt_method_id;
    p_default_cust_bank_account_id := l_cust_bank_account_id;

    p_default_ship_via             := p_crtrx_ship_via;
    p_default_ship_date_actual     := p_crtrx_ship_date_actual;
    p_default_waybill_number       := p_crtrx_waybill_number;
    p_default_fob_point            := p_crtrx_fob_point;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_process_credit_util.get_cm_header_defaults()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION : get_cm_header_defaults');
    END IF;
    RAISE;

END get_cm_header_defaults;

PROCEDURE init IS
BEGIN

  pg_set_of_books_id   :=
          arp_trx_global.system_info.system_parameters.set_of_books_id;
END init;

BEGIN
  init;
END ARP_PROCESS_CREDIT_UTIL;


/
