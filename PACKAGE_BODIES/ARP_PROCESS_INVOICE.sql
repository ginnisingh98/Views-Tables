--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_INVOICE" AS
/* $Header: ARTEINVB.pls 115.5 2003/08/28 17:24:36 kmahajan ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    header_post_insert                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Header post-insert logic for invoices                                  |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE header_post_insert (p_primary_salesrep_id IN
                                ra_customer_trx.primary_salesrep_id%type,
                              p_customer_trx_id IN
                                ra_customer_trx.customer_trx_id%type,
                              p_create_default_sc_flag IN varchar2 DEFAULT 'Y'
                             )

IS

  l_srep_rec     ra_cust_trx_line_salesreps%rowtype;
  l_cust_trx_line_salesrep_id
                 ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type;


BEGIN

   arp_util.debug('arp_process_invoice.header_post_insert()+');

   IF (p_primary_salesrep_id <> -3)       AND
      (p_primary_salesrep_id is not null) AND
      (p_create_default_sc_flag = 'Y')
     THEN

       l_srep_rec.customer_trx_id       := p_customer_trx_id;
       l_srep_rec.salesrep_id           := p_primary_salesrep_id;
       -- kmahajan - 08/25/2003 - added line below for Sales Group project
       l_srep_rec.revenue_salesgroup_id := arp_util.Get_Default_SalesGroup(p_primary_salesrep_id, p_customer_trx_id);
       l_srep_rec.revenue_percent_split := 100;

       arp_ctls_pkg.insert_p(l_srep_rec,
                             l_cust_trx_line_salesrep_id);
   END IF;

   arp_util.debug('arp_process_invoice.header_post_insert()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_invoice.header_post_insert()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    tax_post_update                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Tax post-update logic for invoices                                     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE tax_post_update IS

BEGIN

   arp_util.debug('arp_process_invoice.tax_post_update()+');

   arp_util.debug('arp_process_invoice.tax_post_update()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_invoice.tax_post_update()');
     RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    freight_post_update                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Freight post-update logic for invoices                                 |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_frt_rec                                                  |
 |                p_gl_date                                                  |
 |                p_frt_ccid                                                 |
 |              OUT:                                                         |
 |                p_status                                                   |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     12-JUL-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE freight_post_update(
  p_frt_rec               IN ra_customer_trx_lines%rowtype,
  p_gl_date               IN ra_cust_trx_line_gl_dist.gl_date%type,
  p_frt_ccid              IN
                           ra_cust_trx_line_gl_dist.code_combination_id%type,
  p_status                OUT NOCOPY varchar2)
IS
  l_ccid
                        ra_cust_trx_line_gl_dist.code_combination_id%type;
  l_concat_segments             varchar2(200);
  l_num_failed_dist_rows        number;
  l_rows_processed              number;
  l_errorbuf                    varchar2(200);
  l_result                      number;
BEGIN

   arp_util.debug('arp_process_invoice.freight_post_update()+');

   p_status := 'OK';

   BEGIN
          arp_auto_accounting.do_autoaccounting(
                                'U',
                                'FREIGHT',
                                p_frt_rec.customer_trx_id,
                                p_frt_rec.customer_trx_line_id,
                                null,
                                null,
                                p_gl_date,
                                null,
                                p_frt_rec.extended_amount,
                                p_frt_ccid,
                                null,
                                null,
                                null,
                                null,
                                null,
                                l_ccid,
                                l_concat_segments,
                                l_num_failed_dist_rows);
   EXCEPTION
     WHEN arp_auto_accounting.no_ccid THEN
       p_status:= 'ARP_AUTO_ACCOUNTING.NO_CCID';

     WHEN NO_DATA_FOUND THEN
       null;
     WHEN OTHERS THEN
       RAISE;
   END;


   arp_util.debug('arp_process_invoice.freight_post_update()-');

EXCEPTION
    WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_process_invoice.freight_post_update()');
     arp_util.debug('p_customer_trx_line_id : '||p_frt_rec.customer_trx_line_id);
     arp_util.debug('p_frt_ccid             : '||p_frt_ccid);
     arp_util.debug('p_gl_date              : '||p_gl_date);
     RAISE;

END;


END ARP_PROCESS_INVOICE;

/
