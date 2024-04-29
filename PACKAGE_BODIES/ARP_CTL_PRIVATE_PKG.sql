--------------------------------------------------------
--  DDL for Package Body ARP_CTL_PRIVATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CTL_PRIVATE_PKG" AS
/* $Header: ARTCTL2B.pls 120.2 2005/06/23 23:00:59 djancis ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_rec                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_line_rec                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Subash C            Created                                |
 |     07-APR-05  Debbie Sue Jancis   ETax: Added Ship to Id's               |
 +===========================================================================*/
PROCEDURE display_line_rec(
            p_line_rec IN ra_customer_trx_lines%rowtype) IS
BEGIN
   arp_util.debug('arp_ctl_private_pkg.display_line_rec()+');

   arp_util.debug('******** Dump of ra_customer_trx_lines record *********');
   arp_util.debug('customer_trx_line_id           : '||
                                     p_line_rec.customer_trx_line_id);
   arp_util.debug('customer_trx_id                : '||
                                     p_line_rec.customer_trx_id);

   arp_util.debug('initial_customer_trx_line_id   : '||
                                     p_line_rec.initial_customer_trx_line_id);
   arp_util.debug('link_to_cust_trx_line_id       : '||
                                     p_line_rec.link_to_cust_trx_line_id);

   arp_util.debug('line_type                      : '||p_line_rec.line_type);
   arp_util.debug('line_number                    : '||p_line_rec.line_number);
   arp_util.debug('inventory_item_id              : '||
                                     p_line_rec.inventory_item_id);
   arp_util.debug('memo_line_id                   : '||p_line_rec.memo_line_id);
   arp_util.debug('description                    : '||p_line_rec.description);
   arp_util.debug('quantity_ordered               : '||
                                     p_line_rec.quantity_ordered);
   arp_util.debug('quantity_credited              : '||
                                     p_line_rec.quantity_credited);
   arp_util.debug('quantity_invoiced              : '||
                                     p_line_rec.quantity_invoiced);
   arp_util.debug('uom_code                       : '||p_line_rec.uom_code);
   arp_util.debug('unit_standard_price            : '||
                                     p_line_rec.unit_standard_price);
   arp_util.debug('unit_selling_price             : '||
                                     p_line_rec.unit_selling_price);
   arp_util.debug('extended_amount                : '||
                                     p_line_rec.extended_amount);
   arp_util.debug('revenue_amount                 : '||
                                     p_line_rec.revenue_amount);

   arp_util.debug('reason_code                    : '||
                                     p_line_rec.reason_code);
   arp_util.debug('previous_customer_trx_id       : '||
                                     p_line_rec.previous_customer_trx_id);
   arp_util.debug('previous_customer_trx_line_id  : '||
                                     p_line_rec.previous_customer_trx_line_id);

   arp_util.debug('accounting_rule_id             : '||
                                     p_line_rec.accounting_rule_id);
   arp_util.debug('accounting_rule_duration       : '||
                                     p_line_rec.accounting_rule_duration);
   arp_util.debug('rule_start_date                : '||
                                     p_line_rec.rule_start_date);
   arp_util.debug('autorule_duration_processed    : '||
                                     p_line_rec.autorule_duration_processed);
   arp_util.debug('autorule_complete_flag         : '||
                                     p_line_rec.autorule_complete_flag);
   arp_util.debug('last_period_to_credit          : '||
                                     p_line_rec.last_period_to_credit);

   arp_util.debug('taxable_flag                   : '||p_line_rec.taxable_flag);
   arp_util.debug('tax_precedence                 : '||
                                     p_line_rec.tax_precedence);
   arp_util.debug('tax_rate                       : '||p_line_rec.tax_rate);
   arp_util.debug('item_exception_rate_id         : '||
                                     p_line_rec.item_exception_rate_id);
   arp_util.debug('tax_exemption_id               : '||
                                     p_line_rec.tax_exemption_id);
   arp_util.debug('vat_tax_id                     : '||p_line_rec.vat_tax_id);
   arp_util.debug('autotax                        : '||p_line_rec.autotax);
   arp_util.debug('item_context                   : '||p_line_rec.item_context);
   arp_util.debug('tax_exempt_flag                : '||
                                     p_line_rec.tax_exempt_flag);
   arp_util.debug('tax_exempt_number              : '||
                                     p_line_rec.tax_exempt_number);
   arp_util.debug('tax_exempt_reason_code         : '||
                                     p_line_rec.tax_exempt_reason_code);
   arp_util.debug('tax_vendor_return_code         : '||
                                     p_line_rec.tax_vendor_return_code);
   arp_util.debug('sales_tax_id                   : '||
                                     p_line_rec.sales_tax_id);
   arp_util.debug('location_segment_id            : '||
                                     p_line_rec.location_segment_id);

   -- arp_util.debug('last_update_date               : '||
   --                                   p_line_rec.last_update_date);
   arp_util.debug('last_updated_by                : '||
                                     p_line_rec.last_updated_by);
   -- arp_util.debug('creation_date                  : '||
   --                                   p_line_rec.creation_date);
   arp_util.debug('created_by                     : '||p_line_rec.created_by);
   arp_util.debug('last_update_login              : '||
                                     p_line_rec.last_update_login);
   arp_util.debug('request_id                     : '||p_line_rec.request_id);
   arp_util.debug('program_application_id         : '||
                                     p_line_rec.program_application_id);
   arp_util.debug('program_id                     : '||p_line_rec.program_id);
   -- arp_util.debug('program_update_date            : '||
   --                                   p_line_rec.program_update_date);

   arp_util.debug('set_of_books_id                : '||
                                     p_line_rec.set_of_books_id);
   arp_util.debug('sales_order_source             : '||
                                     p_line_rec.sales_order_source);
   arp_util.debug('sales_order                    : '||
                                     p_line_rec.sales_order);
   arp_util.debug('sales_order_revision           : '||
                                     p_line_rec.sales_order_revision);
   arp_util.debug('sales_order_line               : '||
                                     p_line_rec.sales_order_line);
   arp_util.debug('sales_order_date               : '||
                                     p_line_rec.sales_order_date);
   arp_util.debug('movement_id                    : '||
                                     p_line_rec.movement_id);

   arp_util.debug('attribute_category             : '||
                                     p_line_rec.attribute_category);
   arp_util.debug('attribute1                     : '||p_line_rec.attribute1);
   arp_util.debug('attribute2                     : '||p_line_rec.attribute2);
   arp_util.debug('attribute3                     : '||p_line_rec.attribute3);
   arp_util.debug('attribute4                     : '||p_line_rec.attribute4);
   arp_util.debug('attribute5                     : '||p_line_rec.attribute5);
   arp_util.debug('attribute6                     : '||p_line_rec.attribute6);
   arp_util.debug('attribute7                     : '||p_line_rec.attribute7);
   arp_util.debug('attribute8                     : '||p_line_rec.attribute8);
   arp_util.debug('attribute9                     : '||p_line_rec.attribute9);
   arp_util.debug('attribute10                    : '||p_line_rec.attribute10);
   arp_util.debug('attribute11                    : '||p_line_rec.attribute11);
   arp_util.debug('attribute12                    : '||p_line_rec.attribute12);
   arp_util.debug('attribute13                    : '||p_line_rec.attribute13);
   arp_util.debug('attribute14                    : '||p_line_rec.attribute14);
   arp_util.debug('attribute15                    : '||p_line_rec.attribute15);

   arp_util.debug('interface_line_context         : '||
                                     p_line_rec.interface_line_context);
   arp_util.debug('interface_line_attribute1      : '||
                                     p_line_rec.interface_line_attribute1);
   arp_util.debug('interface_line_attribute2      : '||
                                     p_line_rec.interface_line_attribute2);
   arp_util.debug('interface_line_attribute3      : '||
                                     p_line_rec.interface_line_attribute3);
   arp_util.debug('interface_line_attribute4      : '||
                                     p_line_rec.interface_line_attribute4);
   arp_util.debug('interface_line_attribute5      : '||
                                     p_line_rec.interface_line_attribute5);
   arp_util.debug('interface_line_attribute6      : '||
                                     p_line_rec.interface_line_attribute6);
   arp_util.debug('interface_line_attribute7      : '||
                                     p_line_rec.interface_line_attribute7);
   arp_util.debug('interface_line_attribute8      : '||
                                     p_line_rec.interface_line_attribute8);
   arp_util.debug('interface_line_attribute9      : '||
                                     p_line_rec.interface_line_attribute9);
   arp_util.debug('interface_line_attribute10     : '||
                                     p_line_rec.interface_line_attribute10);
   arp_util.debug('interface_line_attribute11     : '||
                                     p_line_rec.interface_line_attribute11);
   arp_util.debug('interface_line_attribute12     : '||
                                     p_line_rec.interface_line_attribute12);
   arp_util.debug('interface_line_attribute13     : '||
                                     p_line_rec.interface_line_attribute13);
   arp_util.debug('interface_line_attribute14     : '||
                                     p_line_rec.interface_line_attribute14);
   arp_util.debug('interface_line_attribute15     : '||
                                     p_line_rec.interface_line_attribute15);

   arp_util.debug('default_ussgl_trx_code_context : '||
                                     p_line_rec.default_ussgl_trx_code_context);
   arp_util.debug('default_ussgl_transaction_code : '||
                                     p_line_rec.default_ussgl_transaction_code);
   arp_util.debug('payment_set_id : '||
                                     p_line_rec.payment_set_id);

   arp_util.debug('ship_to_customer_id : ' ||
                             p_line_rec.ship_to_customer_id);

   arp_util.debug('ship_to_site_use_id : ' ||
                             p_line_rec.ship_to_site_use_id);

   arp_util.debug('ship_to_contact_id : ' ||
                             p_line_rec.ship_to_contact_id);

   arp_util.debug('tax_classification_code : ' ||
                             p_line_rec.tax_classification_code);

   arp_util.debug('arp_ctl_private_pkg.display_line_rec()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctl_private_pkg.display_line_rec()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_p                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_customer_trx_line_id                              |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-95  Subash C            Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE display_line_p(
            p_customer_trx_line_id IN
                   ra_customer_trx_lines.customer_trx_line_id%type) IS

   l_line_rec ra_customer_trx_lines%rowtype;
BEGIN
   arp_util.debug('arp_ctl_private_pkg.display_line_p()+');

   arp_ctl_pkg.fetch_p(l_line_rec, p_customer_trx_line_id);

   arp_ctl_private_pkg.display_line_rec(l_line_rec);

   arp_util.debug('arp_ctl_private_pkg.display_line_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_ctl_private_pkg.display_line_p()');

        arp_util.debug('');
        arp_util.debug('-------- parameters for display_line_p() ------');
        arp_util.debug('p_customer_trx_line_id  = ' ||
                       p_customer_trx_line_id);

        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_f_lctl_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_link_to_cust_trx_line_id			     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     03-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_line_f_lctl_id(  p_link_to_cust_trx_line_id IN
                         ra_customer_trx_lines.link_to_cust_trx_line_id%type)
                   IS


   CURSOR line_cursor IS
          SELECT *
          FROM   ra_customer_trx_lines
          WHERE  link_to_cust_trx_line_id = p_link_to_cust_trx_line_id
          ORDER BY line_type,
                   line_number;


BEGIN

   arp_util.debug('arp_ctl_private_pkg.display_line_f_lctl_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('========== ' ||
                  ' Dump of ra_customer_trx_lines records for ltctlid: '||
		  to_char( p_link_to_cust_trx_line_id ) || ' ' ||
                  '==========');

   FOR l_line_rec IN line_cursor LOOP
       display_line_p(l_line_rec.customer_trx_line_id);
   END LOOP;

   arp_util.debug('====== End ' ||
                  ' Dump of ra_customer_trx_lines records for ltctlid: '||
		  to_char( p_link_to_cust_trx_line_id ) || ' ' ||
                  '=======');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_ctl_private_pkg.display_line_f_lctl_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctl_private_pkg.display_line_f_lctl_id()');

        arp_util.debug('');
        arp_util.debug('-------- parameters for display_line_p() ------');
        arp_util.debug('p_link_to_cust_trx_line_id  = ' ||
                       p_link_to_cust_trx_line_id);

   RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_line_f_ct_id						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and 	     |
 |    last_update_date.							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-AUG-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE display_line_f_ct_id(  p_customer_trx_id IN
                                        ra_customer_trx.customer_trx_id%type )
                   IS


   CURSOR line_cursor IS
          SELECT *
          FROM   ra_customer_trx_lines
          WHERE  customer_trx_id = p_customer_trx_id
          ORDER BY line_type,
                   line_number;


BEGIN

   arp_util.debug('arp_ctl_private_pkg.display_line_f_ct_id()+');

   arp_util.debug('=====================================================' ||
                  '==========================');
   arp_util.debug('========== ' ||
                  ' Dump of ra_customer_trx_lines records for ctid: '||
		  to_char( p_customer_trx_id ) || ' ' ||
                  '==========');

   FOR l_line_rec IN line_cursor LOOP
       display_line_p(l_line_rec.customer_trx_line_id);
   END LOOP;

   arp_util.debug('====== End ' ||
                  ' Dump of ra_customer_trx_lines records for ctid: '||
		  to_char( p_customer_trx_id ) || ' ' ||
                  '=======');
   arp_util.debug('=====================================================' ||
                  '==========================');

   arp_util.debug('arp_ctl_private_pkg.display_line_f_ct_id()-');

EXCEPTION
 WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_ctl_private_pkg.display_line_f_ct_id()');

   arp_util.debug('');
   arp_util.debug('-------- parameters for display_line_f_ct_id() ------');
   arp_util.debug('p_customer_trx_id  = ' ||
                       p_customer_trx_id);

   RAISE;

END;

END ARP_CTL_PRIVATE_PKG;

/
