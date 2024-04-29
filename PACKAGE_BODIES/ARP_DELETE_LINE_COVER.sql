--------------------------------------------------------
--  DDL for Package Body ARP_DELETE_LINE_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DELETE_LINE_COVER" AS
/* $Header: ARTCTLDB.pls 115.6 2004/05/04 10:16:09 verao ship $ */

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_line_cover						             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Converts column parameters to a line record and                        |
 |    delete a dist line.                                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		   p_form_name					             |
 |		   p_form_version					     |
 |                 p_customer_trx_line_id                                    |
 |                 p_complete_flag                                           |
 |                 p_recalculate_tax_flag                                    |
 |                 p_trx_amount                                              |
 |                 p_exchange_rate                                           |
 |                 p_customer_trx_id                                         |
 |                 p_line_number                                             |
 |                 p_line_type                                               |
 |                 p_quantity_credited                                       |
 |                 p_quantity_invoiced                                       |
 |                 p_quantity_ordered                                        |
 |                 p_unit_selling_price                                      |
 |                 p_unit_standard_price                                     |
 |                 p_revenue_amount                                          |
 |                 p_extended_amount                                         |
 |                 p_memo_line_id                                            |
 |                 p_inventory_item_id                                       |
 |                 p_item_exception_rate_id                                  |
 |                 p_description                                             |
 |                 p_item_context                                            |
 |                 p_initial_customer_trx_line_id                            |
 |                 p_link_to_cust_trx_line_id                                |
 |                 p_previous_customer_trx_id                                |
 |                 p_prev_customer_trx_line_id                               |
 |                 p_accounting_rule_duration                                |
 |                 p_accounting_rule_id                                      |
 |                 p_rule_start_date                                         |
 |                 p_autorule_complete_flag                                  |
 |                 p_autorule_duration_processed                             |
 |                 p_reason_code                                             |
 |                 p_last_period_to_credit                                   |
 |                 p_sales_order                                             |
 |                 p_sales_order_date                                        |
 |                 p_sales_order_line                                        |
 |                 p_sales_order_revision                                    |
 |                 p_sales_order_source                                      |
 |                 p_vat_tax_id                                              |
 |                 p_tax_exempt_flag                                         |
 |                 p_sales_tax_id                                            |
 |                 p_location_segment_id                                     |
 |                 p_tax_exempt_number                                       |
 |                 p_tax_exempt_reason_code                                  |
 |                 p_tax_vendor_return_code                                  |
 |                 p_taxable_flag                                            |
 |                 p_tax_exemption_id                                        |
 |                 p_tax_precedence                                          |
 |                 p_tax_rate                                                |
 |                 p_uom_code                                                |
 |                 p_autotax                                                 |
 |                 p_movement_id                                             |
 |                 p_default_ussgl_trx_code                                  |
 |                 p_default_ussgl_trx_code_cntxt                            |
 |                 p_interface_line_context                                  |
 |                 p_interface_line_attribute1                               |
 |                 p_interface_line_attribute2                               |
 |                 p_interface_line_attribute3                               |
 |                 p_interface_line_attribute4                               |
 |                 p_interface_line_attribute5                               |
 |                 p_interface_line_attribute6                               |
 |                 p_interface_line_attribute7                               |
 |                 p_interface_line_attribute8                               |
 |                 p_interface_line_attribute9                               |
 |                 p_interface_line_attribute10                              |
 |                 p_interface_line_attribute11                              |
 |                 p_interface_line_attribute12                              |
 |                 p_interface_line_attribute13                              |
 |                 p_interface_line_attribute14                              |
 |                 p_interface_line_attribute15                              |
 |                 p_attribute_category                                      |
 |                 p_attribute1                                              |
 |                 p_attribute2                                              |
 |                 p_attribute3                                              |
 |                 p_attribute4                                              |
 |                 p_attribute5                                              |
 |                 p_attribute6                                              |
 |                 p_attribute7                                              |
 |                 p_attribute8                                              |
 |                 p_attribute9                                              |
 |                 p_attribute10                                             |
 |                 p_attribute11                                             |
 |                 p_attribute12                                             |
 |                 p_attribute13                                             |
 |                 p_attribute14                                             |
 |                 p_attribute15                                             |
 |     New in R11: p_header_currency_code				     |
 |		   p_gross_extended_amount				     |
 |		   p_gross_unit_selling_price				     |
 |		   p_amount_includes_tax_flag				     |
 |                 p_global_attribute_category                               |
 |                 p_global_attribute1                                       |
 |                 p_global_attribute2                                       |
 |                 p_global_attribute3                                       |
 |                 p_global_attribute4                                       |
 |                 p_global_attribute5                                       |
 |                 p_global_attribute6                                       |
 |                 p_global_attribute7                                       |
 |                 p_global_attribute8                                       |
 |                 p_global_attribute9                                       |
 |                 p_global_attribute10                                      |
 |                 p_global_attribute11                                      |
 |                 p_global_attribute12                                      |
 |                 p_global_attribute13                                      |
 |                 p_global_attribute14                                      |
 |                 p_global_attribute15                                      |
 |                 p_global_attribute16                                      |
 |                 p_global_attribute17                                      |
 |                 p_global_attribute18                                      |
 |                 p_global_attribute19                                      |
 |                 p_global_attribute20                                      |
 |                                                                           |
 |              OUT:                                                         |
 |                    p_status                                               |
 |          IN/ OUT:							     |
 |                    p_gl_date                                              |
 |                    p_trx_date                                             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-DEC-95  Martin Johnson      Created                                |
 |     20-MAY-96  Martin Johnson      BugNo:356814.  Added OUT NOCOPY parameter     |
 |                                      p_status                             |
 |      Rel. 11 Changes:
 |
 |      24-JUL-97  OSTEINME           added new parameters for Rel.11:
 |                                      p_header_currency_code
 |					p_gross_extended_amount
 |					p_gross_unit_selling_price
 |					p_amount_includes_tax_flag
 |      28-AUG-97  Govind Jayanth     Added global desc.flex columns for
 |                                    Rel 11.
 |                                                                           |
 +===========================================================================*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/* Bug 3567353 */
pg_base_precision            fnd_currencies.precision%type;
pg_base_min_acc_unit         fnd_currencies.minimum_accountable_unit%type;
pg_trx_header_level_rounding ar_system_parameters.trx_header_level_rounding%type;

PROCEDURE delete_line_cover(
           p_form_name IN
             varchar2,
           p_form_version IN
             number,
           p_customer_trx_line_id IN
             ra_customer_trx_lines.customer_trx_line_id%type,
           p_complete_flag IN
             ra_customer_trx.complete_flag%type,
           p_recalculate_tax_flag IN
             boolean,
           p_trx_amount IN
             number,
           p_exchange_rate IN
             ra_customer_trx.exchange_rate%type,
           p_gl_date IN OUT NOCOPY
             ra_cust_trx_line_gl_dist.gl_date%type,
	   p_trx_date IN OUT NOCOPY
             ra_customer_trx.trx_date%type,
           p_customer_trx_id IN
             ra_customer_trx_lines.customer_trx_id%type,
           p_line_number IN
             ra_customer_trx_lines.line_number%type,
           p_line_type IN
             ra_customer_trx_lines.line_type%type,
           p_quantity_credited IN
             ra_customer_trx_lines.quantity_credited%type,
           p_quantity_invoiced IN
             ra_customer_trx_lines.quantity_invoiced%type,
           p_quantity_ordered IN
             ra_customer_trx_lines.quantity_ordered%type,
           p_unit_selling_price IN
             ra_customer_trx_lines.unit_selling_price%type,
           p_unit_standard_price IN
             ra_customer_trx_lines.unit_standard_price%type,
           p_revenue_amount IN
             ra_customer_trx_lines.revenue_amount%type,
           p_extended_amount IN
             ra_customer_trx_lines.extended_amount%type,
           p_memo_line_id IN
             ra_customer_trx_lines.memo_line_id%type,
           p_inventory_item_id IN
             ra_customer_trx_lines.inventory_item_id%type,
           p_item_exception_rate_id IN
             ra_customer_trx_lines.item_exception_rate_id%type,
           p_description IN
             ra_customer_trx_lines.description%type,
           p_item_context IN
             ra_customer_trx_lines.item_context%type,
           p_initial_customer_trx_line_id IN
             ra_customer_trx_lines.initial_customer_trx_line_id%type,
           p_link_to_cust_trx_line_id IN
             ra_customer_trx_lines.link_to_cust_trx_line_id%type,
           p_previous_customer_trx_id IN
             ra_customer_trx_lines.previous_customer_trx_id%type,
           p_prev_customer_trx_line_id IN
             ra_customer_trx_lines.previous_customer_trx_line_id%type,
           p_accounting_rule_duration IN
             ra_customer_trx_lines.accounting_rule_duration%type,
           p_accounting_rule_id IN
             ra_customer_trx_lines.accounting_rule_id%type,
           p_rule_start_date IN
             ra_customer_trx_lines.rule_start_date%type,
           p_autorule_complete_flag IN
             ra_customer_trx_lines.autorule_complete_flag%type,
           p_autorule_duration_processed IN
             ra_customer_trx_lines.autorule_duration_processed%type,
           p_reason_code IN
             ra_customer_trx_lines.reason_code%type,
           p_last_period_to_credit IN
             ra_customer_trx_lines.last_period_to_credit%type,
           p_sales_order IN
             ra_customer_trx_lines.sales_order%type,
           p_sales_order_date IN
             ra_customer_trx_lines.sales_order_date%type,
           p_sales_order_line IN
             ra_customer_trx_lines.sales_order_line%type,
           p_sales_order_revision IN
             ra_customer_trx_lines.sales_order_revision%type,
           p_sales_order_source IN
             ra_customer_trx_lines.sales_order_source%type,
           p_vat_tax_id IN
             ra_customer_trx_lines.vat_tax_id%type,
           p_tax_exempt_flag IN
             ra_customer_trx_lines.tax_exempt_flag%type,
           p_sales_tax_id IN
             ra_customer_trx_lines.sales_tax_id%type,
           p_location_segment_id IN
             ra_customer_trx_lines.location_segment_id%type,
           p_tax_exempt_number IN
             ra_customer_trx_lines.tax_exempt_number%type,
           p_tax_exempt_reason_code IN
             ra_customer_trx_lines.tax_exempt_reason_code%type,
           p_tax_vendor_return_code IN
             ra_customer_trx_lines.tax_vendor_return_code%type,
           p_taxable_flag IN
             ra_customer_trx_lines.taxable_flag%type,
           p_tax_exemption_id IN
             ra_customer_trx_lines.tax_exemption_id%type,
           p_tax_precedence IN
             ra_customer_trx_lines.tax_precedence%type,
           p_tax_rate IN
             ra_customer_trx_lines.tax_rate%type,
           p_uom_code IN
             ra_customer_trx_lines.uom_code%type,
           p_autotax IN
             ra_customer_trx_lines.autotax%type,
           p_movement_id IN
             ra_customer_trx_lines.movement_id%type,
           p_default_ussgl_trx_code IN
             ra_customer_trx_lines.default_ussgl_transaction_code%type,
           p_default_ussgl_trx_code_cntxt IN
             ra_customer_trx_lines.default_ussgl_trx_code_context%type,
           p_interface_line_context IN
             ra_customer_trx_lines.interface_line_context%type,
           p_interface_line_attribute1 IN
             ra_customer_trx_lines.interface_line_attribute1%type,
           p_interface_line_attribute2 IN
             ra_customer_trx_lines.interface_line_attribute2%type,
           p_interface_line_attribute3 IN
             ra_customer_trx_lines.interface_line_attribute3%type,
           p_interface_line_attribute4 IN
             ra_customer_trx_lines.interface_line_attribute4%type,
           p_interface_line_attribute5 IN
             ra_customer_trx_lines.interface_line_attribute5%type,
           p_interface_line_attribute6 IN
             ra_customer_trx_lines.interface_line_attribute6%type,
           p_interface_line_attribute7 IN
             ra_customer_trx_lines.interface_line_attribute7%type,
           p_interface_line_attribute8 IN
             ra_customer_trx_lines.interface_line_attribute8%type,
           p_interface_line_attribute9 IN
             ra_customer_trx_lines.interface_line_attribute9%type,
           p_interface_line_attribute10 IN
             ra_customer_trx_lines.interface_line_attribute10%type,
           p_interface_line_attribute11 IN
             ra_customer_trx_lines.interface_line_attribute11%type,
           p_interface_line_attribute12 IN
             ra_customer_trx_lines.interface_line_attribute12%type,
           p_interface_line_attribute13 IN
             ra_customer_trx_lines.interface_line_attribute13%type,
           p_interface_line_attribute14 IN
             ra_customer_trx_lines.interface_line_attribute14%type,
           p_interface_line_attribute15 IN
             ra_customer_trx_lines.interface_line_attribute15%type,
           p_attribute_category IN
             ra_customer_trx_lines.attribute_category%type,
           p_attribute1 IN
             ra_customer_trx_lines.attribute1%type,
           p_attribute2 IN
             ra_customer_trx_lines.attribute2%type,
           p_attribute3 IN
             ra_customer_trx_lines.attribute3%type,
           p_attribute4 IN
             ra_customer_trx_lines.attribute4%type,
           p_attribute5 IN
             ra_customer_trx_lines.attribute5%type,
           p_attribute6 IN
             ra_customer_trx_lines.attribute6%type,
           p_attribute7 IN
             ra_customer_trx_lines.attribute7%type,
           p_attribute8 IN
             ra_customer_trx_lines.attribute8%type,
           p_attribute9 IN
             ra_customer_trx_lines.attribute9%type,
           p_attribute10 IN
             ra_customer_trx_lines.attribute10%type,
           p_attribute11 IN
             ra_customer_trx_lines.attribute11%type,
           p_attribute12 IN
             ra_customer_trx_lines.attribute12%type,
           p_attribute13 IN
             ra_customer_trx_lines.attribute13%type,
           p_attribute14 IN
             ra_customer_trx_lines.attribute14%type,
           p_attribute15 IN
             ra_customer_trx_lines.attribute15%type,
           p_header_currency_code IN
		ra_customer_trx.invoice_currency_code%type,
	   p_gross_extended_amount IN
		ra_customer_trx_lines.gross_extended_amount%type,
	   p_gross_unit_selling_price IN
		ra_customer_trx_lines.gross_unit_selling_price%type,
	   p_amount_includes_tax_flag IN
		ra_customer_trx_lines.amount_includes_tax_flag%type,
           p_status      OUT NOCOPY
             varchar2,
           p_global_attribute_category IN
             ra_customer_trx_lines.global_attribute_category%type,
           p_global_attribute1 IN
             ra_customer_trx_lines.global_attribute1%type,
           p_global_attribute2 IN
             ra_customer_trx_lines.global_attribute2%type,
           p_global_attribute3 IN
             ra_customer_trx_lines.global_attribute3%type,
           p_global_attribute4 IN
             ra_customer_trx_lines.global_attribute4%type,
           p_global_attribute5 IN
             ra_customer_trx_lines.global_attribute5%type,
           p_global_attribute6 IN
             ra_customer_trx_lines.global_attribute6%type,
           p_global_attribute7 IN
             ra_customer_trx_lines.global_attribute7%type,
           p_global_attribute8 IN
             ra_customer_trx_lines.global_attribute8%type,
           p_global_attribute9 IN
             ra_customer_trx_lines.global_attribute9%type,
           p_global_attribute10 IN
             ra_customer_trx_lines.global_attribute10%type,
           p_global_attribute11 IN
             ra_customer_trx_lines.global_attribute11%type,
           p_global_attribute12 IN
             ra_customer_trx_lines.global_attribute12%type,
           p_global_attribute13 IN
             ra_customer_trx_lines.global_attribute13%type,
           p_global_attribute14 IN
             ra_customer_trx_lines.global_attribute14%type,
           p_global_attribute15 IN
             ra_customer_trx_lines.global_attribute15%type,
           p_global_attribute16 IN
             ra_customer_trx_lines.global_attribute16%type,
           p_global_attribute17 IN
             ra_customer_trx_lines.global_attribute17%type,
           p_global_attribute18 IN
             ra_customer_trx_lines.global_attribute18%type,
           p_global_attribute19 IN
             ra_customer_trx_lines.global_attribute19%type,
           p_global_attribute20 IN
             ra_customer_trx_lines.global_attribute20%type,
           p_payment_set_id IN
             ra_customer_trx_lines.payment_set_id%type )
IS

  l_line_rec ra_customer_trx_lines%rowtype;

  /* bug 3567353 */
  l_error_message VARCHAR2(128) := '';
  l_dist_count NUMBER;
  l_rules_check_flag VARCHAR2(1);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_delete_line_cover.delete_line_cover()+');
  END IF;

  /*------------------------------------------------+
   |  Populate the line record group with           |
   |  the values passed in as parameters.           |
   +------------------------------------------------*/

  l_line_rec.customer_trx_id := p_customer_trx_id;
  l_line_rec.payment_set_id := p_payment_set_id;
  l_line_rec.line_number := p_line_number;
  l_line_rec.line_type := p_line_type;
  l_line_rec.quantity_credited := p_quantity_credited;
  l_line_rec.quantity_invoiced := p_quantity_invoiced;
  l_line_rec.quantity_ordered := p_quantity_ordered;
  l_line_rec.unit_selling_price := p_unit_selling_price;
  l_line_rec.unit_standard_price := p_unit_standard_price;
  l_line_rec.revenue_amount := p_revenue_amount;
  l_line_rec.extended_amount := p_extended_amount;
  l_line_rec.memo_line_id := p_memo_line_id;
  l_line_rec.inventory_item_id := p_inventory_item_id;
  l_line_rec.item_exception_rate_id := p_item_exception_rate_id;
  l_line_rec.description := p_description;
  l_line_rec.item_context := p_item_context;
  l_line_rec.initial_customer_trx_line_id := p_initial_customer_trx_line_id;
  l_line_rec.link_to_cust_trx_line_id := p_link_to_cust_trx_line_id;
  l_line_rec.previous_customer_trx_id := p_previous_customer_trx_id;
  l_line_rec.previous_customer_trx_line_id := p_prev_customer_trx_line_id;
  l_line_rec.accounting_rule_duration := p_accounting_rule_duration;
  l_line_rec.accounting_rule_id := p_accounting_rule_id;
  l_line_rec.rule_start_date := p_rule_start_date;
  l_line_rec.autorule_complete_flag := p_autorule_complete_flag;
  l_line_rec.autorule_duration_processed := p_autorule_duration_processed;
  l_line_rec.reason_code := p_reason_code;
  l_line_rec.last_period_to_credit := p_last_period_to_credit;
  l_line_rec.sales_order := p_sales_order;
  l_line_rec.sales_order_date := p_sales_order_date;
  l_line_rec.sales_order_line := p_sales_order_line;
  l_line_rec.sales_order_revision := p_sales_order_revision;
  l_line_rec.sales_order_source := p_sales_order_source;
  l_line_rec.vat_tax_id := p_vat_tax_id;
  l_line_rec.tax_exempt_flag := p_tax_exempt_flag;
  l_line_rec.sales_tax_id := p_sales_tax_id;
  l_line_rec.location_segment_id := p_location_segment_id;
  l_line_rec.tax_exempt_number := p_tax_exempt_number;
  l_line_rec.tax_exempt_reason_code := p_tax_exempt_reason_code;
  l_line_rec.tax_vendor_return_code := p_tax_vendor_return_code;
  l_line_rec.taxable_flag := p_taxable_flag;
  l_line_rec.tax_exemption_id := p_tax_exemption_id;
  l_line_rec.tax_precedence := p_tax_precedence;
  l_line_rec.tax_rate := p_tax_rate;
  l_line_rec.uom_code := p_uom_code;
  l_line_rec.autotax := p_autotax;
  l_line_rec.movement_id := p_movement_id;
  l_line_rec.default_ussgl_transaction_code :=
                                  p_default_ussgl_trx_code;
  l_line_rec.default_ussgl_trx_code_context :=
                                  p_default_ussgl_trx_code_cntxt;
  l_line_rec.interface_line_context := p_interface_line_context;
  l_line_rec.interface_line_attribute1 := p_interface_line_attribute1;
  l_line_rec.interface_line_attribute2 := p_interface_line_attribute2;
  l_line_rec.interface_line_attribute3 := p_interface_line_attribute3;
  l_line_rec.interface_line_attribute4 := p_interface_line_attribute4;
  l_line_rec.interface_line_attribute5 := p_interface_line_attribute5;
  l_line_rec.interface_line_attribute6 := p_interface_line_attribute6;
  l_line_rec.interface_line_attribute7 := p_interface_line_attribute7;
  l_line_rec.interface_line_attribute8 := p_interface_line_attribute8;
  l_line_rec.interface_line_attribute9 := p_interface_line_attribute9;
  l_line_rec.interface_line_attribute10 := p_interface_line_attribute10;
  l_line_rec.interface_line_attribute11 := p_interface_line_attribute11;
  l_line_rec.interface_line_attribute12 := p_interface_line_attribute12;
  l_line_rec.interface_line_attribute13 := p_interface_line_attribute13;
  l_line_rec.interface_line_attribute14 := p_interface_line_attribute14;
  l_line_rec.interface_line_attribute15 := p_interface_line_attribute15;
  l_line_rec.attribute_category := p_attribute_category;
  l_line_rec.attribute1 := p_attribute1;
  l_line_rec.attribute2 := p_attribute2;
  l_line_rec.attribute3 := p_attribute3;
  l_line_rec.attribute4 := p_attribute4;
  l_line_rec.attribute5 := p_attribute5;
  l_line_rec.attribute6 := p_attribute6;
  l_line_rec.attribute7 := p_attribute7;
  l_line_rec.attribute8 := p_attribute8;
  l_line_rec.attribute9 := p_attribute9;
  l_line_rec.attribute10 := p_attribute10;
  l_line_rec.attribute11 := p_attribute11;
  l_line_rec.attribute12 := p_attribute12;
  l_line_rec.attribute13 := p_attribute13;
  l_line_rec.attribute14 := p_attribute14;
  l_line_rec.attribute15 := p_attribute15;

  -- Rel. 11 Changes:

  l_line_rec.gross_unit_selling_price := p_gross_unit_selling_price;
  l_line_rec.gross_extended_amount := p_gross_extended_amount;
  l_line_rec.amount_includes_tax_flag := p_amount_includes_tax_flag;

  -- Rel. 11 Changes: Global Desc. Flex.

  l_line_rec.global_attribute_category := p_global_attribute_category;
  l_line_rec.global_attribute1 := p_global_attribute1;
  l_line_rec.global_attribute2 := p_global_attribute2;
  l_line_rec.global_attribute3 := p_global_attribute3;
  l_line_rec.global_attribute4 := p_global_attribute4;
  l_line_rec.global_attribute5 := p_global_attribute5;
  l_line_rec.global_attribute6 := p_global_attribute6;
  l_line_rec.global_attribute7 := p_global_attribute7;
  l_line_rec.global_attribute8 := p_global_attribute8;
  l_line_rec.global_attribute9 := p_global_attribute9;
  l_line_rec.global_attribute10 := p_global_attribute10;
  l_line_rec.global_attribute11 := p_global_attribute11;
  l_line_rec.global_attribute12 := p_global_attribute12;
  l_line_rec.global_attribute13 := p_global_attribute13;
  l_line_rec.global_attribute14 := p_global_attribute14;
  l_line_rec.global_attribute15 := p_global_attribute15;
  l_line_rec.global_attribute16 := p_global_attribute16;
  l_line_rec.global_attribute17 := p_global_attribute17;
  l_line_rec.global_attribute18 := p_global_attribute18;
  l_line_rec.global_attribute19 := p_global_attribute19;
  l_line_rec.global_attribute20 := p_global_attribute20;


  /*----------------------------------------+
   |  Call the standard dist entity handler |
   +----------------------------------------*/

  arp_process_line.delete_line(
                       p_form_name,
                       p_form_version,
                       p_customer_trx_line_id,
                       p_complete_flag,
		       p_recalculate_tax_flag,
                       p_trx_amount,
                       p_exchange_rate,
		       p_header_currency_code,
	 	       p_gl_date,
	 	       p_trx_date,
                       l_line_rec,
                       p_status );

  /*  bug 3567353 Call rounding   */
  IF p_rule_start_date IS NULL THEN
     l_rules_check_flag  := 'N';
  ELSE
     l_rules_check_flag  := 'Y';
  END IF;
  IF  arp_rounding.correct_dist_rounding_errors(
                                        NULL,
                                        l_line_rec.CUSTOMER_TRX_ID ,
                                        p_customer_trx_line_id ,
                                        l_dist_count,
                                        l_error_message ,
                                        pg_base_precision ,
                                        pg_base_min_acc_unit ,
                                        'ALL' ,
                                        l_rules_check_flag,
                                        'N' ,
                                        pg_trx_header_level_rounding ,
                                        'N',
                                        'N') = 0 -- FALSE
  THEN
     arp_util.debug('EXCEPTION: arp_delete_line_cover.delete_line_cover ');
     arp_util.debug(l_error_message);
     fnd_message.set_name('AR', 'AR_PLCRE_FHLR_CCID');
     APP_EXCEPTION.raise_exception;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_delete_line_cover.delete_line_cover()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_delete_line_cover.delete_line_cover()');
       arp_util.debug('------- parameters for delete_line_cover() ' ||
                   '---------');
       arp_util.debug('delete_line_cover: ' || 'p_form_name = ' || p_form_name);
       arp_util.debug('delete_line_cover: ' || 'p_form_version = ' || p_form_version);
       arp_util.debug('delete_line_cover: ' || 'p_customer_trx_line_id = ' || p_customer_trx_line_id);
       arp_util.debug('delete_line_cover: ' || 'p_complete_flag  = ' || p_complete_flag );
       arp_util.debug('delete_line_cover: ' || 'p_recalculate_tax_flag  = ' ||
              arp_trx_util.boolean_to_varchar2(p_recalculate_tax_flag) );
       arp_util.debug('delete_line_cover: ' || 'p_trx_amount  = ' || p_trx_amount );
       arp_util.debug('delete_line_cover: ' || 'p_exchange_rate = ' || p_exchange_rate);
       arp_util.debug('delete_line_cover: ' || 'p_gl_date  = ' || p_gl_date);
       arp_util.debug('delete_line_cover: ' || 'p_trx_date = ' || p_trx_date);
       arp_util.debug('delete_line_cover: ' || 'p_customer_trx_id = ' || p_customer_trx_id);
       arp_util.debug('delete_line_cover: ' || 'p_line_number = ' || p_line_number);
       arp_util.debug('delete_line_cover: ' || 'p_line_type = ' || p_line_type);
       arp_util.debug('delete_line_cover: ' || 'p_quantity_invoiced = ' || p_quantity_invoiced);
       arp_util.debug('delete_line_cover: ' || 'p_quantity_ordered = ' || p_quantity_ordered);
       arp_util.debug('delete_line_cover: ' || 'p_unit_selling_price = ' || p_unit_selling_price);
       arp_util.debug('delete_line_cover: ' || 'p_unit_standard_price = ' || p_unit_standard_price);
       arp_util.debug('delete_line_cover: ' || 'p_revenue_amount = ' || p_revenue_amount);
       arp_util.debug('delete_line_cover: ' || 'p_extended_amount = ' || p_extended_amount);
       arp_util.debug('delete_line_cover: ' || 'p_memo_line_id = ' || p_memo_line_id);
       arp_util.debug('delete_line_cover: ' || 'p_inventory_item_id = ' || p_inventory_item_id);
       arp_util.debug('delete_line_cover: ' || 'p_item_exception_rate_id = ' || p_item_exception_rate_id);
       arp_util.debug('delete_line_cover: ' || 'p_description = ' || p_description);
       arp_util.debug('delete_line_cover: ' || 'p_item_context = ' || p_item_context);
       arp_util.debug('delete_line_cover: ' || 'p_initial_customer_trx_line_id = ' ||
                                      p_initial_customer_trx_line_id);
       arp_util.debug('delete_line_cover: ' || 'p_link_to_cust_trx_line_id = ' ||
                                      p_link_to_cust_trx_line_id);
       arp_util.debug('delete_line_cover: ' || 'p_previous_customer_trx_id = ' ||
                                      p_previous_customer_trx_id);
       arp_util.debug('delete_line_cover: ' || 'p_prev_customer_trx_line_id = ' ||
                                      p_prev_customer_trx_line_id);
       arp_util.debug('delete_line_cover: ' || 'p_accounting_rule_duration = ' ||
                                      p_accounting_rule_duration);
       arp_util.debug('delete_line_cover: ' || 'p_accounting_rule_id = ' || p_accounting_rule_id);
       arp_util.debug('delete_line_cover: ' || 'p_rule_start_date = ' || p_rule_start_date);
       arp_util.debug('delete_line_cover: ' || 'p_autorule_complete_flag = ' || p_autorule_complete_flag);
       arp_util.debug('delete_line_cover: ' || 'p_autorule_duration_processed = ' ||
                                      p_autorule_duration_processed);
       arp_util.debug('delete_line_cover: ' || 'p_reason_code = ' || p_reason_code);
       arp_util.debug('delete_line_cover: ' || 'p_last_period_to_credit = ' || p_last_period_to_credit);
       arp_util.debug('delete_line_cover: ' || 'p_sales_order = ' || p_sales_order);
       arp_util.debug('delete_line_cover: ' || 'p_sales_order_date = ' || p_sales_order_date);
       arp_util.debug('delete_line_cover: ' || 'p_sales_order_line = ' || p_sales_order_line);
       arp_util.debug('delete_line_cover: ' || 'p_sales_order_revision = ' || p_sales_order_revision);
       arp_util.debug('delete_line_cover: ' || 'p_sales_order_source = ' || p_sales_order_source);
       arp_util.debug('delete_line_cover: ' || 'p_vat_tax_id = ' || p_vat_tax_id);
       arp_util.debug('delete_line_cover: ' || 'p_tax_exempt_flag = ' || p_tax_exempt_flag);
       arp_util.debug('delete_line_cover: ' || 'p_sales_tax_id = ' || p_sales_tax_id);
       arp_util.debug('delete_line_cover: ' || 'p_location_segment_id = ' || p_location_segment_id);
       arp_util.debug('delete_line_cover: ' || 'p_tax_exempt_number = ' || p_tax_exempt_number);
       arp_util.debug('delete_line_cover: ' || 'p_tax_exempt_reason_code = ' || p_tax_exempt_reason_code);
       arp_util.debug('delete_line_cover: ' || 'p_tax_vendor_return_code = ' || p_tax_vendor_return_code);
       arp_util.debug('delete_line_cover: ' || 'p_taxable_flag = ' || p_taxable_flag);
       arp_util.debug('delete_line_cover: ' || 'p_tax_exemption_id = ' || p_tax_exemption_id);
       arp_util.debug('delete_line_cover: ' || 'p_tax_precedence = ' || p_tax_precedence);
       arp_util.debug('delete_line_cover: ' || 'p_tax_rate = ' || p_tax_rate);
       arp_util.debug('delete_line_cover: ' || 'p_uom_code = ' || p_uom_code);
       arp_util.debug('delete_line_cover: ' || 'p_autotax = ' || p_autotax);
       arp_util.debug('delete_line_cover: ' || 'p_movement_id = ' || p_movement_id);
       arp_util.debug('delete_line_cover: ' || 'p_default_ussgl_trx_code = ' ||
                      p_default_ussgl_trx_code);
       arp_util.debug('delete_line_cover: ' || 'p_default_ussgl_trx_code_cntxt = ' ||
                      p_default_ussgl_trx_code_cntxt);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_context = ' || p_interface_line_context);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute1 = ' ||
                      p_interface_line_attribute1);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute2 = ' ||
                      p_interface_line_attribute2);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute3 = ' ||
                      p_interface_line_attribute3);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute4 = ' ||
                      p_interface_line_attribute4);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute5 = ' ||
                      p_interface_line_attribute5);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute6 = ' ||
                      p_interface_line_attribute6);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute7 = ' ||
                      p_interface_line_attribute7);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute8 = ' ||
                      p_interface_line_attribute8);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute9 = ' ||
                      p_interface_line_attribute9);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute10 = ' ||
                      p_interface_line_attribute10);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute11 = ' ||
                      p_interface_line_attribute11);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute12 = ' ||
                      p_interface_line_attribute12);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute13 = ' ||
                      p_interface_line_attribute13);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute14 = ' ||
                      p_interface_line_attribute14);
       arp_util.debug('delete_line_cover: ' || 'p_interface_line_attribute15 = ' ||
                      p_interface_line_attribute15);
       arp_util.debug('delete_line_cover: ' || 'p_attribute_category = ' || p_attribute_category);
       arp_util.debug('delete_line_cover: ' || 'p_attribute1 = ' || p_attribute1);
       arp_util.debug('delete_line_cover: ' || 'p_attribute2 = ' || p_attribute2);
       arp_util.debug('delete_line_cover: ' || 'p_attribute3 = ' || p_attribute3);
       arp_util.debug('delete_line_cover: ' || 'p_attribute4 = ' || p_attribute4);
       arp_util.debug('delete_line_cover: ' || 'p_attribute5 = ' || p_attribute5);
       arp_util.debug('delete_line_cover: ' || 'p_attribute6 = ' || p_attribute6);
       arp_util.debug('delete_line_cover: ' || 'p_attribute7 = ' || p_attribute7);
       arp_util.debug('delete_line_cover: ' || 'p_attribute8 = ' || p_attribute8);
       arp_util.debug('delete_line_cover: ' || 'p_attribute9 = ' || p_attribute9);
       arp_util.debug('delete_line_cover: ' || 'p_attribute10 = ' || p_attribute10);
       arp_util.debug('delete_line_cover: ' || 'p_attribute11 = ' || p_attribute11);
       arp_util.debug('delete_line_cover: ' || 'p_attribute12 = ' || p_attribute12);
       arp_util.debug('delete_line_cover: ' || 'p_attribute13 = ' || p_attribute13);
       arp_util.debug('delete_line_cover: ' || 'p_attribute14 = ' || p_attribute14);
       arp_util.debug('delete_line_cover: ' || 'p_attribute15 = ' || p_attribute15);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute_category = ' || p_global_attribute_category);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute1 = ' || p_global_attribute1);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute2 = ' || p_global_attribute2);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute3 = ' || p_global_attribute3);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute4 = ' || p_global_attribute4);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute5 = ' || p_global_attribute5);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute6 = ' || p_global_attribute6);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute7 = ' || p_global_attribute7);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute8 = ' || p_global_attribute8);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute9 = ' || p_global_attribute9);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute10 = ' || p_global_attribute10);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute11 = ' || p_global_attribute11);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute12 = ' || p_global_attribute12);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute13 = ' || p_global_attribute13);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute14 = ' || p_global_attribute14);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute15 = ' || p_global_attribute15);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute16 = ' || p_global_attribute16);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute17 = ' || p_global_attribute17);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute18 = ' || p_global_attribute18);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute19 = ' || p_global_attribute19);
       arp_util.debug('delete_line_cover: ' || 'p_global_attribute20 = ' || p_global_attribute20);
       arp_util.debug('delete_line_cover: ' || 'p_payment_set_id = ' || p_payment_set_id);
    END IF;

    RAISE;

END delete_line_cover;

BEGIN
  /* bug 3567353 */
  pg_base_precision             := arp_global.base_precision;
  pg_base_min_acc_unit          := arp_global.base_min_acc_unit;
  pg_trx_header_level_rounding  := arp_global.sysparam.trx_header_level_rounding;

END ARP_DELETE_LINE_COVER;

/
