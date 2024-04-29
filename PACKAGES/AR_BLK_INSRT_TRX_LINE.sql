--------------------------------------------------------
--  DDL for Package AR_BLK_INSRT_TRX_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BLK_INSRT_TRX_LINE" AUTHID CURRENT_USER AS
/* $Header: ARTXBLKS.pls 120.2 2005/10/30 04:27:44 appldev noship $ */

TYPE t_customer_trx_line_id is TABLE of ra_customer_trx_lines.customer_trx_line_id%TYPE index by binary_integer;
TYPE t_customer_trx_id is TABLE of ra_customer_trx_lines.customer_trx_id%TYPE index by binary_integer;
TYPE t_line_number  is TABLE of ra_customer_trx_lines.line_number%TYPE index by binary_integer;
TYPE t_line_type is TABLE of ra_customer_trx_lines.line_type%TYPE index by binary_integer;
TYPE t_quantity_credited is TABLE of ra_customer_trx_lines.quantity_credited%TYPE index by binary_integer;
TYPE t_quantity_invoiced is TABLE of ra_customer_trx_lines.quantity_invoiced%TYPE index by binary_integer ;
TYPE t_quantity_ordered is TABLE of ra_customer_trx_lines.quantity_ordered%TYPE index by binary_integer;
TYPE t_unit_selling_price is TABLE of ra_customer_trx_lines.unit_selling_price%TYPE index by binary_integer;
TYPE t_unit_standard_price is TABLE of ra_customer_trx_lines.unit_standard_price%TYPE index by binary_integer;
TYPE t_revenue_amount is TABLE of ra_customer_trx_lines.revenue_amount%TYPE index by binary_integer;
TYPE t_extended_amount is TABLE of ra_customer_trx_lines.extended_amount%TYPE index by binary_integer;
TYPE t_memo_line_id is TABLE of ra_customer_trx_lines.memo_line_id%TYPE index by binary_integer;
TYPE t_inventory_item_id is TABLE of ra_customer_trx_lines.inventory_item_id%TYPE index by binary_integer;
TYPE t_item_exception_rate_id is TABLE of ra_customer_trx_lines.item_exception_rate_id%TYPE index by binary_integer;
TYPE t_description is TABLE of ra_customer_trx_lines.description%TYPE index by binary_integer;
TYPE t_item_context is TABLE of ra_customer_trx_lines.item_context%TYPE index by binary_integer;
TYPE t_initial_trx_line_id is TABLE of ra_customer_trx_lines.initial_customer_trx_line_id%TYPE index by binary_integer;
TYPE t_link_to_cust_trx_line_id is TABLE of ra_customer_trx_lines.link_to_cust_trx_line_id%TYPE index by binary_integer;
TYPE t_prev_customer_trx_id is TABLE of ra_customer_trx_lines.previous_customer_trx_id%TYPE index by binary_integer;
TYPE t_prev_customer_trx_line_id is TABLE of ra_customer_trx_lines.previous_customer_trx_line_id%TYPE index by binary_integer;
TYPE t_accounting_rule_duration is TABLE of ra_customer_trx_lines.accounting_rule_duration%TYPE index by binary_integer;
TYPE t_accounting_rule_id is TABLE of ra_customer_trx_lines.accounting_rule_id%TYPE index by binary_integer;
TYPE t_rule_start_date is TABLE of ra_customer_trx_lines.rule_start_date%TYPE index by binary_integer;
TYPE t_autorule_complete_flag is TABLE of ra_customer_trx_lines.autorule_complete_flag%TYPE index by binary_integer;
TYPE t_autorule_duration_processed is TABLE of ra_customer_trx_lines.autorule_duration_processed%TYPE index by binary_integer;
TYPE t_reason_code is TABLE of ra_customer_trx_lines.reason_code%TYPE index by binary_integer;
TYPE t_last_period_to_credit is TABLE of ra_customer_trx_lines.last_period_to_credit%TYPE index by binary_integer;
TYPE t_sales_order is TABLE of ra_customer_trx_lines.sales_order%TYPE index by binary_integer;
TYPE t_sales_order_date is TABLE of ra_customer_trx_lines.sales_order_date%TYPE index by binary_integer;
TYPE t_sales_order_line is TABLE of ra_customer_trx_lines.sales_order_line%TYPE index by binary_integer;
TYPE t_sales_order_revision is TABLE of ra_customer_trx_lines.sales_order_revision%TYPE index by binary_integer;
TYPE t_sales_order_source is TABLE of ra_customer_trx_lines.sales_order_source%TYPE index by binary_integer;
TYPE t_vat_tax_id is TABLE of ra_customer_trx_lines.vat_tax_id%TYPE index by binary_integer;
TYPE t_tax_exempt_flag is TABLE of ra_customer_trx_lines.tax_exempt_flag%TYPE index by binary_integer;
TYPE t_sales_tax_id is TABLE of ra_customer_trx_lines.sales_tax_id%TYPE index by binary_integer;
TYPE t_location_segment_id is TABLE of ra_customer_trx_lines.location_segment_id%TYPE index by binary_integer;
TYPE t_tax_exempt_number is TABLE of ra_customer_trx_lines.tax_exempt_number%TYPE index by binary_integer;
TYPE t_tax_exempt_reason_code is TABLE of ra_customer_trx_lines.tax_exempt_reason_code%TYPE index by binary_integer;
TYPE t_tax_vendor_return_code is TABLE of ra_customer_trx_lines.tax_vendor_return_code%TYPE index by binary_integer;
TYPE t_taxable_flag is TABLE of ra_customer_trx_lines.taxable_flag%TYPE index by binary_integer;
TYPE t_tax_exemption_id is TABLE of ra_customer_trx_lines.tax_exemption_id%TYPE index by binary_integer;
TYPE t_tax_precedence is TABLE of ra_customer_trx_lines.tax_precedence%TYPE index by binary_integer;
TYPE t_tax_rate is TABLE of ra_customer_trx_lines.tax_rate%TYPE index by binary_integer;
TYPE t_uom_code is TABLE of ra_customer_trx_lines.uom_code%TYPE index by binary_integer;
TYPE t_autotax is TABLE of ra_customer_trx_lines.autotax%TYPE index by binary_integer;
TYPE t_movement_id is TABLE of ra_customer_trx_lines.movement_id%TYPE index by binary_integer;
TYPE t_DEF_ussgl_transaction_code is TABLE of ra_customer_trx_lines.default_ussgl_transaction_code%TYPE index by binary_integer;
TYPE t_DEF_ussgl_trx_code_context is TABLE of ra_customer_trx_lines.default_ussgl_trx_code_context%TYPE index by binary_integer;
TYPE t_interface_line_context is TABLE of ra_customer_trx_lines.interface_line_context%TYPE index by binary_integer;
TYPE t_interface_line_attribute1 is TABLE of ra_customer_trx_lines.interface_line_attribute1%TYPE index by binary_integer;
TYPE t_interface_line_attribute2 is TABLE of ra_customer_trx_lines.interface_line_attribute2%TYPE index by binary_integer;
TYPE t_interface_line_attribute3 is TABLE of ra_customer_trx_lines.interface_line_attribute3%TYPE index by binary_integer;
TYPE t_interface_line_attribute4 is TABLE of ra_customer_trx_lines.interface_line_attribute4%TYPE index by binary_integer;
TYPE t_interface_line_attribute5 is TABLE of ra_customer_trx_lines.interface_line_attribute5%TYPE index by binary_integer;
TYPE t_interface_line_attribute6 is TABLE of ra_customer_trx_lines.interface_line_attribute6%TYPE index by binary_integer;
TYPE t_interface_line_attribute7 is TABLE of ra_customer_trx_lines.interface_line_attribute7%TYPE index by binary_integer;
TYPE t_interface_line_attribute8 is TABLE of ra_customer_trx_lines.interface_line_attribute8%TYPE index by binary_integer;
TYPE t_interface_line_attribute9 is TABLE of ra_customer_trx_lines.interface_line_attribute9%TYPE index by binary_integer;
TYPE t_interface_line_attribute10 is TABLE of ra_customer_trx_lines.interface_line_attribute10%TYPE index by binary_integer;
TYPE t_interface_line_attribute11 is TABLE of ra_customer_trx_lines.interface_line_attribute11%TYPE index by binary_integer;
TYPE t_interface_line_attribute12 is TABLE of ra_customer_trx_lines.interface_line_attribute12%TYPE index by binary_integer;
TYPE t_interface_line_attribute13 is TABLE of ra_customer_trx_lines.interface_line_attribute13%TYPE index by binary_integer;
TYPE t_interface_line_attribute14 is TABLE of ra_customer_trx_lines.interface_line_attribute14%TYPE index by binary_integer;
TYPE t_interface_line_attribute15 is TABLE of ra_customer_trx_lines.interface_line_attribute15%TYPE index by binary_integer;
TYPE t_attribute_category is TABLE of ra_customer_trx_lines.attribute_category%TYPE index by binary_integer;
TYPE t_attribute1 is TABLE of ra_customer_trx_lines.attribute1%TYPE index by binary_integer;
TYPE t_attribute2 is TABLE of ra_customer_trx_lines.attribute2%TYPE index by binary_integer;
TYPE t_attribute3 is TABLE of ra_customer_trx_lines.attribute3%TYPE index by binary_integer;
TYPE t_attribute4 is TABLE of ra_customer_trx_lines.attribute4%TYPE index by binary_integer;
TYPE t_attribute5 is TABLE of ra_customer_trx_lines.attribute5%TYPE index by binary_integer;
TYPE t_attribute6 is TABLE of ra_customer_trx_lines.attribute6%TYPE index by binary_integer;
TYPE t_attribute7 is TABLE of ra_customer_trx_lines.attribute7%TYPE index by binary_integer;
TYPE t_attribute8 is TABLE of ra_customer_trx_lines.attribute8%TYPE index by binary_integer;
TYPE t_attribute9 is TABLE of ra_customer_trx_lines.attribute9%TYPE index by binary_integer;
TYPE t_attribute10 is TABLE of ra_customer_trx_lines.attribute10%TYPE index by binary_integer;
TYPE t_attribute11 is TABLE of ra_customer_trx_lines.attribute11%TYPE index by binary_integer;
TYPE t_attribute12 is TABLE of ra_customer_trx_lines.attribute12%TYPE index by binary_integer;
TYPE t_attribute13 is TABLE of ra_customer_trx_lines.attribute13%TYPE index by binary_integer;
TYPE t_attribute14 is TABLE of ra_customer_trx_lines.attribute14%TYPE index by binary_integer;
TYPE t_attribute15 is TABLE of ra_customer_trx_lines.attribute15%TYPE index by binary_integer;
TYPE t_global_attribute_category is TABLE of ra_customer_trx_lines.global_attribute_category%TYPE index by binary_integer;
TYPE t_global_attribute1 is TABLE of ra_customer_trx_lines.global_attribute1%TYPE index by binary_integer;
TYPE t_global_attribute2 is TABLE of ra_customer_trx_lines.global_attribute2%TYPE index by binary_integer;
TYPE t_global_attribute3 is TABLE of ra_customer_trx_lines.global_attribute3%TYPE index by binary_integer;
TYPE t_global_attribute4 is TABLE of ra_customer_trx_lines.global_attribute4%TYPE index by binary_integer;
TYPE t_global_attribute5 is TABLE of ra_customer_trx_lines.global_attribute5%TYPE index by binary_integer;
TYPE t_global_attribute6 is TABLE of ra_customer_trx_lines.global_attribute6%TYPE index by binary_integer;
TYPE t_global_attribute7 is TABLE of ra_customer_trx_lines.global_attribute7%TYPE index by binary_integer;
TYPE t_global_attribute8 is TABLE of ra_customer_trx_lines.global_attribute8%TYPE index by binary_integer;
TYPE t_global_attribute9 is TABLE of ra_customer_trx_lines.global_attribute9%TYPE index by binary_integer;
TYPE t_global_attribute10 is TABLE of ra_customer_trx_lines.global_attribute10%TYPE index by binary_integer;
TYPE t_global_attribute11 is TABLE of ra_customer_trx_lines.global_attribute11%TYPE index by binary_integer;
TYPE t_global_attribute12 is TABLE of ra_customer_trx_lines.global_attribute12%TYPE index by binary_integer;
TYPE t_global_attribute13 is TABLE of ra_customer_trx_lines.global_attribute13%TYPE index by binary_integer;
TYPE t_global_attribute14 is TABLE of ra_customer_trx_lines.global_attribute14%TYPE index by binary_integer;
TYPE t_global_attribute15 is TABLE of ra_customer_trx_lines.global_attribute15%TYPE index by binary_integer;
TYPE t_global_attribute16 is TABLE of ra_customer_trx_lines.global_attribute16%TYPE index by binary_integer;
TYPE t_global_attribute17 is TABLE of ra_customer_trx_lines.global_attribute17%TYPE index by binary_integer;
TYPE t_global_attribute18 is TABLE of ra_customer_trx_lines.global_attribute18%TYPE index by binary_integer;
TYPE t_global_attribute19 is TABLE of ra_customer_trx_lines.global_attribute19%TYPE index by binary_integer;
TYPE t_global_attribute20 is TABLE of ra_customer_trx_lines.global_attribute20%TYPE index by binary_integer;
TYPE t_created_by is TABLE of ra_customer_trx_lines.created_by%TYPE index by binary_integer;
TYPE t_create_date is TABLE of ra_customer_trx_lines.creation_date%TYPE index by binary_integer;
TYPE t_updated_by is TABLE of ra_customer_trx_lines.last_updated_by%TYPE index by binary_integer;
TYPE t_update_date is TABLE of ra_customer_trx_lines.last_update_date%TYPE index by binary_integer;
TYPE t_prog_appl_id is TABLE of ra_customer_trx_lines.program_application_id%TYPE index by binary_integer;
TYPE t_last_update_login is TABLE of ra_customer_trx_lines.last_update_login%TYPE index by binary_integer;
TYPE t_conc_program_id is TABLE of ra_customer_trx_lines.program_id%TYPE index by binary_integer;
TYPE t_program_update_date is TABLE of ra_customer_trx_lines.program_update_date%TYPE index by binary_integer;
TYPE t_set_of_books_id is TABLE of ra_customer_trx_lines.set_of_books_id%TYPE index by binary_integer;
TYPE t_gross_unit_selling_price is TABLE of ra_customer_trx_lines.gross_unit_selling_price%TYPE index by binary_integer;
TYPE t_gross_extended_amount is TABLE of ra_customer_trx_lines.gross_extended_amount%TYPE index by binary_integer;
TYPE t_amount_includes_tax_flag is TABLE of ra_customer_trx_lines.amount_includes_tax_flag%TYPE index by binary_integer;
TYPE t_warehouse_id is TABLE of ra_customer_trx_lines.warehouse_id%TYPE index by binary_integer;
TYPE t_translated_description is TABLE of ra_customer_trx_lines.translated_description%TYPE index by binary_integer;
TYPE t_taxable_amount is TABLE of ra_customer_trx_lines.taxable_amount%TYPE index by binary_integer;
TYPE t_request_id is TABLE of ra_customer_trx_lines.request_id%TYPE index by binary_integer;
TYPE t_extended_acctd_amount is TABLE of ra_customer_trx_lines.extended_acctd_amount%TYPE index by binary_integer;
TYPE t_br_ref_customer_trx_id is TABLE of ra_customer_trx_lines.br_ref_customer_trx_id%TYPE index by binary_integer;
TYPE t_br_ref_payment_schedule_id is TABLE of ra_customer_trx_lines.br_ref_payment_schedule_id%TYPE index by binary_integer;
TYPE t_br_adjustment_id is TABLE of ra_customer_trx_lines.br_adjustment_id%TYPE index by binary_integer;
TYPE t_wh_update_date is TABLE of ra_customer_trx_lines.wh_update_date%TYPE index by binary_integer;


PROCEDURE bulk_insert_cust_trx_lines (
              p_customer_trx_line_id         IN OUT NOCOPY t_customer_trx_line_id,
              p_customer_trx_id              IN OUT NOCOPY t_customer_trx_id,
              p_line_number                  IN OUT NOCOPY t_line_number,
              p_line_type                    IN OUT NOCOPY t_line_type,
              p_quantity_credited            IN OUT NOCOPY t_quantity_credited,
              p_quantity_invoiced            IN OUT NOCOPY t_quantity_invoiced,
              p_quantity_ordered             IN OUT NOCOPY t_quantity_ordered,
              p_unit_selling_price           IN OUT NOCOPY t_unit_selling_price,
              p_unit_standard_price          IN OUT NOCOPY t_unit_standard_price,
              p_revenue_amount               IN OUT NOCOPY t_revenue_amount,
              p_extended_amount              IN OUT NOCOPY t_extended_amount,
              p_memo_line_id                 IN OUT NOCOPY t_memo_line_id,
              p_inventory_item_id            IN OUT NOCOPY t_inventory_item_id,
              p_item_exception_rate_id       IN OUT NOCOPY t_item_exception_rate_id,
              p_description                  IN OUT NOCOPY t_description,
              p_item_context                 IN OUT NOCOPY t_item_context,
              p_initial_trx_line_id          IN OUT NOCOPY t_initial_trx_line_id,
              p_link_to_cust_trx_line_id     IN OUT NOCOPY t_link_to_cust_trx_line_id,
              p_prev_customer_trx_id         IN OUT NOCOPY t_prev_customer_trx_id,
              p_prev_customer_trx_line_id    IN OUT NOCOPY t_prev_customer_trx_line_id,
              p_accounting_rule_duration     IN OUT NOCOPY t_accounting_rule_duration,
              p_accounting_rule_id           IN OUT NOCOPY t_accounting_rule_id,
              p_rule_start_date              IN OUT NOCOPY t_rule_start_date,
              p_autorule_complete_flag       IN OUT NOCOPY t_autorule_complete_flag,
              p_autorule_duration_processed  IN OUT NOCOPY t_autorule_duration_processed,
              p_reason_code                  IN OUT NOCOPY t_reason_code,
              p_last_period_to_credit        IN OUT NOCOPY t_last_period_to_credit,
              p_sales_order                  IN OUT NOCOPY t_sales_order,
              p_sales_order_date             IN OUT NOCOPY t_sales_order_date,
              p_sales_order_line             IN OUT NOCOPY t_sales_order_line,
              p_sales_order_revision         IN OUT NOCOPY t_sales_order_revision,
              p_sales_order_source           IN OUT NOCOPY t_sales_order_source,
              p_vat_tax_id                   IN OUT NOCOPY t_vat_tax_id,
              p_tax_exempt_flag              IN OUT NOCOPY t_tax_exempt_flag,
              p_sales_tax_id                 IN OUT NOCOPY t_sales_tax_id,
              p_location_segment_id          IN OUT NOCOPY t_location_segment_id,
              p_tax_exempt_number            IN OUT NOCOPY t_tax_exempt_number,
              p_tax_exempt_reason_code       IN OUT NOCOPY t_tax_exempt_reason_code,
              p_tax_vendor_return_code       IN OUT NOCOPY t_tax_vendor_return_code,
              p_taxable_flag                 IN OUT NOCOPY t_taxable_flag,
              p_tax_exemption_id             IN OUT NOCOPY t_tax_exemption_id,
              p_tax_precedence               IN OUT NOCOPY t_tax_precedence,
              p_tax_rate                     IN OUT NOCOPY t_tax_rate,
              p_uom_code                     IN OUT NOCOPY t_uom_code,
              p_autotax                      IN OUT NOCOPY t_autotax,
              p_movement_id                  IN OUT NOCOPY t_movement_id,
              p_def_ussgl_transaction_code   IN OUT NOCOPY t_def_ussgl_transaction_code,
              p_def_ussgl_trx_code_context   IN OUT NOCOPY t_def_ussgl_trx_code_context,
              p_interface_line_context       IN OUT NOCOPY t_interface_line_context,
              p_interface_line_attribute1    IN OUT NOCOPY t_interface_line_attribute1,
              p_interface_line_attribute2    IN OUT NOCOPY t_interface_line_attribute2,
              p_interface_line_attribute3    IN OUT NOCOPY t_interface_line_attribute3,
              p_interface_line_attribute4    IN OUT NOCOPY t_interface_line_attribute4,
              p_interface_line_attribute5    IN OUT NOCOPY t_interface_line_attribute5,
              p_interface_line_attribute6    IN OUT NOCOPY t_interface_line_attribute6,
              p_interface_line_attribute7    IN OUT NOCOPY t_interface_line_attribute7,
              p_interface_line_attribute8    IN OUT NOCOPY t_interface_line_attribute8,
              p_interface_line_attribute9    IN OUT NOCOPY t_interface_line_attribute9,
              p_interface_line_attribute10   IN OUT NOCOPY t_interface_line_attribute10,
              p_interface_line_attribute11   IN OUT NOCOPY t_interface_line_attribute11,
              p_interface_line_attribute12   IN OUT NOCOPY t_interface_line_attribute12,
              p_interface_line_attribute13   IN OUT NOCOPY t_interface_line_attribute13,
              p_interface_line_attribute14   IN OUT NOCOPY t_interface_line_attribute14,
              p_interface_line_attribute15   IN OUT NOCOPY t_interface_line_attribute15,
              p_attribute_category           IN OUT NOCOPY t_attribute_category,
              p_attribute1                   IN OUT NOCOPY t_attribute1,
              p_attribute2                   IN OUT NOCOPY t_attribute2,
              p_attribute3                   IN OUT NOCOPY t_attribute3,
              p_attribute4                   IN OUT NOCOPY t_attribute4,
              p_attribute5                   IN OUT NOCOPY t_attribute5,
              p_attribute6                   IN OUT NOCOPY t_attribute6,
              p_attribute7                   IN OUT NOCOPY t_attribute7,
              p_attribute8                   IN OUT NOCOPY t_attribute8,
              p_attribute9                   IN OUT NOCOPY t_attribute9,
              p_attribute10                  IN OUT NOCOPY t_attribute10,
              p_attribute11                  IN OUT NOCOPY t_attribute11,
              p_attribute12                  IN OUT NOCOPY t_attribute12,
              p_attribute13                  IN OUT NOCOPY t_attribute13,
              p_attribute14                  IN OUT NOCOPY t_attribute14,
              p_attribute15                  IN OUT NOCOPY t_attribute15,
              p_global_attribute_category    IN OUT NOCOPY t_global_attribute_category,
              p_global_attribute1            IN OUT NOCOPY t_global_attribute1,
              p_global_attribute2            IN OUT NOCOPY t_global_attribute2,
              p_global_attribute3            IN OUT NOCOPY t_global_attribute3,
              p_global_attribute4            IN OUT NOCOPY t_global_attribute4,
              p_global_attribute5            IN OUT NOCOPY t_global_attribute5,
              p_global_attribute6            IN OUT NOCOPY t_global_attribute6,
              p_global_attribute7            IN OUT NOCOPY t_global_attribute7,
              p_global_attribute8            IN OUT NOCOPY t_global_attribute8,
              p_global_attribute9            IN OUT NOCOPY t_global_attribute9,
              p_global_attribute10           IN OUT NOCOPY t_global_attribute10,
              p_global_attribute11           IN OUT NOCOPY t_global_attribute11,
              p_global_attribute12           IN OUT NOCOPY t_global_attribute12,
              p_global_attribute13           IN OUT NOCOPY t_global_attribute13,
              p_global_attribute14           IN OUT NOCOPY t_global_attribute14,
              p_global_attribute15           IN OUT NOCOPY t_global_attribute15,
              p_global_attribute16           IN OUT NOCOPY t_global_attribute16,
              p_global_attribute17           IN OUT NOCOPY t_global_attribute17,
              p_global_attribute18           IN OUT NOCOPY t_global_attribute18,
              p_global_attribute19           IN OUT NOCOPY t_global_attribute19,
              p_global_attribute20           IN OUT NOCOPY t_global_attribute20,
              p_created_by                   IN OUT NOCOPY t_created_by,
              p_create_date                  IN OUT NOCOPY t_create_date,
              p_updated_by                   IN OUT NOCOPY t_updated_by,
              p_update_date                  IN OUT NOCOPY t_update_date,
              p_prog_appl_id                 IN OUT NOCOPY t_prog_appl_id,
              p_last_update_login            IN OUT NOCOPY t_last_update_login,
              p_conc_program_id              IN OUT NOCOPY t_conc_program_id,
              p_program_update_date          IN OUT NOCOPY t_program_update_date,
              p_set_of_books_id              IN OUT NOCOPY t_set_of_books_id,
              p_gross_unit_selling_price     IN OUT NOCOPY t_gross_unit_selling_price,
              p_gross_extended_amount        IN OUT NOCOPY t_gross_extended_amount,
              p_amount_include_tax_flag      IN OUT NOCOPY t_amount_includes_tax_flag,
              p_warehouse_id                 IN OUT NOCOPY t_warehouse_id,
              p_translated_description       IN OUT NOCOPY t_translated_description,
              p_taxable_amount               IN OUT NOCOPY t_taxable_amount,
              p_request_id                   IN OUT NOCOPY t_request_id,
              p_extended_acctd_amount        IN OUT NOCOPY t_extended_acctd_amount,
              p_br_ref_customer_trx_id       IN OUT NOCOPY t_br_ref_customer_trx_id,
              p_br_ref_payment_schedule_id   IN OUT NOCOPY t_br_ref_payment_schedule_id,
              p_br_adjustment_id             IN OUT NOCOPY t_br_adjustment_id,
              p_wh_update_date               IN OUT NOCOPY t_wh_update_date);

END AR_BLK_INSRT_TRX_LINE;


 

/
