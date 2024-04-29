--------------------------------------------------------
--  DDL for Package ARP_DELETE_LINE_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DELETE_LINE_COVER" AUTHID CURRENT_USER AS
/* $Header: ARTCTLDS.pls 115.3 2002/11/15 03:31:18 anukumar ship $ */

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
             ra_customer_trx_lines.payment_set_id%type
);

END ARP_DELETE_LINE_COVER;

 

/
