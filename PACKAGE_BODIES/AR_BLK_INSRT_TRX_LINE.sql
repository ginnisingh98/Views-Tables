--------------------------------------------------------
--  DDL for Package Body AR_BLK_INSRT_TRX_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BLK_INSRT_TRX_LINE" as
/* $Header: ARTXBLKB.pls 120.2 2005/06/14 18:52:57 vcrisost noship $ */


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
              p_wh_update_date               IN OUT NOCOPY t_wh_update_date)

IS

    i      number := 0;
    p_cntr number := 0;

  BEGIN

    arp_standard.debug('AR_BLK_INSRT_TRX_LINE.AR_BLK_INSRT_TRX_LINE(+) ');

    IF p_customer_trx_line_id.count <> 0 then
      forall i in p_customer_trx_line_id.first..p_customer_trx_line_id.last
        INSERT INTO ra_customer_trx_lines (customer_trx_line_id,
                                           customer_trx_id,
                                           line_number,
                                           line_type,
                                           quantity_credited,
                                           quantity_invoiced,
                                           quantity_ordered,
                                           unit_selling_price,
                                           unit_standard_price,
                                           revenue_amount,
                                           extended_amount,
                                           memo_line_id,
                                           inventory_item_id,
                                           item_exception_rate_id,
                                           description,
                                           item_context,
                                           initial_customer_trx_line_id,
                                           link_to_cust_trx_line_id,
                                           previous_customer_trx_id,
                                           previous_customer_trx_line_id,
                                           accounting_rule_duration,
                                           accounting_rule_id,
                                           rule_start_date,
                                           autorule_complete_flag,
                                           autorule_duration_processed,
                                           reason_code,
                                           last_period_to_credit,
                                           sales_order,
                                           sales_order_date,
                                           sales_order_line,
                                           sales_order_revision,
                                           sales_order_source,
                                           vat_tax_id,
                                           tax_exempt_flag,
                                           sales_tax_id,
                                           location_segment_id,
                                           tax_exempt_number,
                                           tax_exempt_reason_code,
                                           tax_vendor_return_code,
                                           taxable_flag,
                                           tax_exemption_id,
                                           tax_precedence,
                                           tax_rate,
                                           uom_code,
                                           autotax,
                                           movement_id,
                                           default_ussgl_transaction_code,
                                           default_ussgl_trx_code_context,
                                           interface_line_context,
                                           interface_line_attribute1,
                                           interface_line_attribute2,
                                           interface_line_attribute3,
                                           interface_line_attribute4,
                                           interface_line_attribute5,
                                           interface_line_attribute6,
                                           interface_line_attribute7,
                                           interface_line_attribute8,
                                           interface_line_attribute9,
                                           interface_line_attribute10,
                                           interface_line_attribute11,
                                           interface_line_attribute12,
                                           interface_line_attribute13,
                                           interface_line_attribute14,
                                           interface_line_attribute15,
                                           attribute_category,
                                           attribute1,
                                           attribute2,
                                           attribute3,
                                           attribute4,
                                           attribute5,
                                           attribute6,
                                           attribute7,
                                           attribute8,
                                           attribute9,
                                           attribute10,
                                           attribute11,
                                           attribute12,
                                           attribute13,
                                           attribute14,
                                           attribute15,
                                           global_attribute_category,
                                           global_attribute1,
                                           global_attribute2,
                                           global_attribute3,
                                           global_attribute4,
                                           global_attribute5,
                                           global_attribute6,
                                           global_attribute7,
                                           global_attribute8,
                                           global_attribute9,
                                           global_attribute10,
                                           global_attribute11,
                                           global_attribute12,
                                           global_attribute13,
                                           global_attribute14,
                                           global_attribute15,
                                           global_attribute16,
                                           global_attribute17,
                                           global_attribute18,
                                           global_attribute19,
                                           global_attribute20,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           program_application_id,
                                           last_update_login,
                                           program_id,
                                           program_update_date,
                                           set_of_books_id,
                                           gross_unit_selling_price,
                                           gross_extended_amount,
                                           amount_includes_tax_flag,
                                           warehouse_id,
                                           translated_description,
                                           taxable_amount,
                                           request_id,
                                           extended_acctd_amount,
                                           br_ref_customer_trx_id,
                                           br_ref_payment_schedule_id,
                                           br_adjustment_id,
                                           wh_update_date,
                                           org_id)
                                   VALUES (p_customer_trx_line_id(i),
                                           p_customer_trx_id(i),
                                           p_line_number(i),
                                           p_line_type(i),
                                           p_quantity_credited(i),
                                           p_quantity_invoiced(i),
                                           p_quantity_ordered(i),
                                           p_unit_selling_price(i),
                                           p_unit_standard_price(i),
                                           p_revenue_amount(i),
                                           p_extended_amount(i),
                                           p_memo_line_id(i),
                                           p_inventory_item_id(i),
                                           p_item_exception_rate_id(i),
                                           p_description(i),
                                           p_item_context(i),
                                           p_initial_trx_line_id(i),
                                           p_link_to_cust_trx_line_id(i),
                                           p_prev_customer_trx_id(i),
                                           p_prev_customer_trx_line_id(i),
                                           p_accounting_rule_duration(i),
                                           p_accounting_rule_id(i),
                                           p_rule_start_date(i),
                                           p_autorule_complete_flag(i),
                                           p_autorule_duration_processed(i),
                                           p_reason_code(i),
                                           p_last_period_to_credit(i),
                                           p_sales_order(i),
                                           p_sales_order_date(i),
                                           p_sales_order_line(i),
                                           p_sales_order_revision(i),
                                           p_sales_order_source(i),
                                           p_vat_tax_id(i),
                                           p_tax_exempt_flag(i),
                                           p_sales_tax_id(i),
                                           p_location_segment_id(i),
                                           p_tax_exempt_number(i),
                                           p_tax_exempt_reason_code(i),
                                           p_tax_vendor_return_code(i),
                                           p_taxable_flag(i),
                                           p_tax_exemption_id(i),
                                           p_tax_precedence(i),
                                           p_tax_rate(i),
                                           p_uom_code(i),
                                           p_autotax(i),
                                           p_movement_id(i),
                                           p_def_ussgl_transaction_code(i),
                                           p_def_ussgl_trx_code_context(i),
                                           p_interface_line_context(i),
                                           p_interface_line_attribute1(i),
                                           p_interface_line_attribute2(i),
                                           p_interface_line_attribute3(i),
                                           p_interface_line_attribute4(i),
                                           p_interface_line_attribute5(i),
                                           p_interface_line_attribute6(i),
                                           p_interface_line_attribute7(i),
                                           p_interface_line_attribute8(i),
                                           p_interface_line_attribute9(i),
                                           p_interface_line_attribute10(i),
                                           p_interface_line_attribute11(i),
                                           p_interface_line_attribute12(i),
                                           p_interface_line_attribute13(i),
                                           p_interface_line_attribute14(i),
                                           p_interface_line_attribute15(i),
                                           p_attribute_category(i),
                                           p_attribute1(i),
                                           p_attribute2(i),
                                           p_attribute3(i),
                                           p_attribute4(i),
                                           p_attribute5(i),
                                           p_attribute6(i),
                                           p_attribute7(i),
                                           p_attribute8(i),
                                           p_attribute9(i),
                                           p_attribute10(i),
                                           p_attribute11(i),
                                           p_attribute12(i),
                                           p_attribute13(i),
                                           p_attribute14(i),
                                           p_attribute15(i),
                                           p_global_attribute_category(i),
                                           p_global_attribute1(i),
                                           p_global_attribute2(i),
                                           p_global_attribute3(i),
                                           p_global_attribute4(i),
                                           p_global_attribute5(i),
                                           p_global_attribute6(i),
                                           p_global_attribute7(i),
                                           p_global_attribute8(i),
                                           p_global_attribute9(i),
                                           p_global_attribute10(i),
                                           p_global_attribute11(i),
                                           p_global_attribute12(i),
                                           p_global_attribute13(i),
                                           p_global_attribute14(i),
                                           p_global_attribute15(i),
                                           p_global_attribute16(i),
                                           p_global_attribute17(i),
                                           p_global_attribute18(i),
                                           p_global_attribute19(i),
                                           p_global_attribute20(i),
                                           p_created_by(i),
                                           p_create_date(i),
                                           p_updated_by(i),
                                           p_program_update_date(i),
                                           p_prog_appl_id(i),
                                           p_last_update_login(i),
                                           p_conc_program_id(i),
                                           p_program_update_date(i),
                                           p_set_of_books_id(i),
                                           p_gross_unit_selling_price(i),
                                           p_gross_extended_amount(i),
                                           p_amount_include_tax_flag(i),
                                           p_warehouse_id(i),
                                           p_translated_description(i),
                                           p_taxable_amount(i),
                                           p_request_id(i),
                                           p_extended_acctd_amount(i),
                                           p_br_ref_customer_trx_id(i),
                                           p_br_ref_payment_schedule_id(i),
                                           p_br_adjustment_id(i),
                                           p_wh_update_date(i),
                                           arp_standard.sysparm.org_id);
        p_cntr := p_cntr + 1;
    end if;

    arp_standard.debug('AR_BLK_INSRT_TRX_LINE.number of records: '||to_char(p_cntr));

    arp_standard.debug('AR_BLK_INSRT_TRX_LINE.bulk_insert_cust_trx_lines(-) ');

    EXCEPTION
      WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  bulk_insert_trx_lines()');
        arp_standard.debug(SQLCODE||' ; '||SQLERRM);

        arp_standard.debug('p_customer_trx_line_id        : '||p_customer_trx_line_id(i));
        arp_standard.debug('p_customer_trx_id             : '||p_customer_trx_id(i));
        arp_standard.debug('p_line_number                 : '||p_line_number(i));
        arp_standard.debug('p_line_type                   : '||p_line_type(i));
        arp_standard.debug('p_quantity_credited           : '||p_quantity_credited(i));
        arp_standard.debug('p_quantity_invoiced           : '||p_quantity_invoiced(i));
        arp_standard.debug('p_quantity_ordered            : '||p_quantity_ordered(i));
        arp_standard.debug('p_unit_selling_price          : '||p_unit_selling_price(i));
        arp_standard.debug('p_unit_standard_price         : '||p_unit_standard_price(i));
        arp_standard.debug('p_revenue_amount              : '||p_revenue_amount(i));
        arp_standard.debug('p_extended_amount             : '||p_extended_amount(i));
        arp_standard.debug('p_memo_line_id                : '||p_memo_line_id(i));
        arp_standard.debug('p_inventory_item_id           : '||p_inventory_item_id(i));
        arp_standard.debug('p_item_exception_rate_id      : '||p_item_exception_rate_id(i));
        arp_standard.debug('p_description                 : '||p_description(i));
        arp_standard.debug('p_item_context                : '||p_item_context(i));
        arp_standard.debug('p_initial_trx_line_id         : '||p_initial_trx_line_id(i));
        arp_standard.debug('p_link_to_cust_trx_line_id    : '||p_link_to_cust_trx_line_id(i));
        arp_standard.debug('p_prev_customer_trx_id        : '||p_prev_customer_trx_id(i));
        arp_standard.debug('p_prev_customer_trx_line_id   : '||p_prev_customer_trx_line_id(i));
        arp_standard.debug('p_accounting_rule_duration    : '||p_accounting_rule_duration(i));
        arp_standard.debug('p_accounting_rule_id          : '||p_accounting_rule_id(i));
        arp_standard.debug('p_rule_start_date             : '||p_rule_start_date(i));
        arp_standard.debug('p_autorule_complete_flag      : '||p_autorule_complete_flag(i));
        arp_standard.debug('p_autorule_duration_processed : '||p_autorule_duration_processed(i));
        arp_standard.debug('p_reason_code                 : '||p_reason_code(i));
        arp_standard.debug('p_last_period_to_credit       : '||p_last_period_to_credit(i));
        arp_standard.debug('p_sales_order                 : '||p_sales_order(i));
        arp_standard.debug('p_sales_order_date            : '||p_sales_order_date(i));
        arp_standard.debug('p_sales_order_line            : '||p_sales_order_line(i));
        arp_standard.debug('p_sales_order_revision        : '||p_sales_order_revision(i));
        arp_standard.debug('p_sales_order_source          : '||p_sales_order_source(i));
        arp_standard.debug('p_vat_tax_id                  : '||p_vat_tax_id(i));
        arp_standard.debug('p_tax_exempt_flag             : '||p_tax_exempt_flag(i));
        arp_standard.debug('p_sales_tax_id                : '||p_sales_tax_id(i));
        arp_standard.debug('p_location_segment_id         : '||p_location_segment_id(i));
        arp_standard.debug('p_tax_exempt_number           : '||p_tax_exempt_number(i));
        arp_standard.debug('p_tax_exempt_reason_code      : '||p_tax_exempt_reason_code(i));
        arp_standard.debug('p_tax_vendor_return_code      : '||p_tax_vendor_return_code(i));
        arp_standard.debug('p_taxable_flag                : '||p_taxable_flag(i));
        arp_standard.debug('p_tax_exemption_id            : '||p_tax_exemption_id(i));
        arp_standard.debug('p_tax_precedence              : '||p_tax_precedence(i));
        arp_standard.debug('p_tax_rate                    : '||p_tax_rate(i));
        arp_standard.debug('p_uom_code                    : '||p_uom_code(i));
        arp_standard.debug('p_autotax                     : '||p_autotax(i));
        arp_standard.debug('p_movement_id                 : '||p_movement_id(i));
        arp_standard.debug('p_def_ussgl_transaction_code  : '||p_def_ussgl_transaction_code(i));
        arp_standard.debug('p_def_ussgl_trx_code_context  : '||p_def_ussgl_trx_code_context(i));
        arp_standard.debug('p_interface_line_context      : '||p_interface_line_context(i));
        arp_standard.debug('p_interface_line_attribute1   : '||p_interface_line_attribute1(i));
        arp_standard.debug('p_interface_line_attribute2   : '||p_interface_line_attribute2(i));
        arp_standard.debug('p_interface_line_attribute3   : '||p_interface_line_attribute3(i));
        arp_standard.debug('p_interface_line_attribute4   : '||p_interface_line_attribute4(i));
        arp_standard.debug('p_interface_line_attribute5   : '||p_interface_line_attribute5(i));
        arp_standard.debug('p_interface_line_attribute6   : '||p_interface_line_attribute6(i));
        arp_standard.debug('p_interface_line_attribute7   : '||p_interface_line_attribute7(i));
        arp_standard.debug('p_interface_line_attribute8   : '||p_interface_line_attribute8(i));
        arp_standard.debug('p_interface_line_attribute9   : '||p_interface_line_attribute9(i));
        arp_standard.debug('p_interface_line_attribute10  : '||p_interface_line_attribute10(i));
        arp_standard.debug('p_interface_line_attribute11  : '||p_interface_line_attribute11(i));
        arp_standard.debug('p_interface_line_attribute12  : '||p_interface_line_attribute12(i));
        arp_standard.debug('p_interface_line_attribute13  : '||p_interface_line_attribute13(i));
        arp_standard.debug('p_interface_line_attribute14  : '||p_interface_line_attribute14(i));
        arp_standard.debug('p_interface_line_attribute15  : '||p_interface_line_attribute15(i));
        arp_standard.debug('p_attribute_category          : '||p_attribute_category(i));
        arp_standard.debug('p_attribute1                  : '||p_attribute1(i));
        arp_standard.debug('p_attribute2                  : '||p_attribute2(i));
        arp_standard.debug('p_attribute3                  : '||p_attribute3(i));
        arp_standard.debug('p_attribute4                  : '||p_attribute4(i));
        arp_standard.debug('p_attribute5                  : '||p_attribute5(i));
        arp_standard.debug('p_attribute6                  : '||p_attribute6(i));
        arp_standard.debug('p_attribute7                  : '||p_attribute7(i));
        arp_standard.debug('p_attribute8                  : '||p_attribute8(i));
        arp_standard.debug('p_attribute9                  : '||p_attribute9(i));
        arp_standard.debug('p_attribute10                 : '||p_attribute10(i));
        arp_standard.debug('p_attribute11                 : '||p_attribute11(i));
        arp_standard.debug('p_attribute12                 : '||p_attribute12(i));
        arp_standard.debug('p_attribute13                 : '||p_attribute13(i));
        arp_standard.debug('p_attribute14                 : '||p_attribute14(i));
        arp_standard.debug('p_attribute15                 : '||p_attribute15(i));
        arp_standard.debug('p_global_attribute_category   : '||p_global_attribute_category(i));
        arp_standard.debug('p_global_attribute1           : '||p_global_attribute1(i));
        arp_standard.debug('p_global_attribute2           : '||p_global_attribute2(i));
        arp_standard.debug('p_global_attribute3           : '||p_global_attribute3(i));
        arp_standard.debug('p_global_attribute4           : '||p_global_attribute4(i));
        arp_standard.debug('p_global_attribute5           : '||p_global_attribute5(i));
        arp_standard.debug('p_global_attribute6           : '||p_global_attribute6(i));
        arp_standard.debug('p_global_attribute7           : '||p_global_attribute7(i));
        arp_standard.debug('p_global_attribute8           : '||p_global_attribute8(i));
        arp_standard.debug('p_global_attribute9           : '||p_global_attribute9(i));
        arp_standard.debug('p_global_attribute10          : '||p_global_attribute10(i));
        arp_standard.debug('p_global_attribute11          : '||p_global_attribute11(i));
        arp_standard.debug('p_global_attribute12          : '||p_global_attribute12(i));
        arp_standard.debug('p_global_attribute13          : '||p_global_attribute13(i));
        arp_standard.debug('p_global_attribute14          : '||p_global_attribute14(i));
        arp_standard.debug('p_global_attribute15          : '||p_global_attribute15(i));
        arp_standard.debug('p_global_attribute16          : '||p_global_attribute16(i));
        arp_standard.debug('p_global_attribute17          : '||p_global_attribute17(i));
        arp_standard.debug('p_global_attribute18          : '||p_global_attribute18(i));
        arp_standard.debug('p_global_attribute19          : '||p_global_attribute19(i));
        arp_standard.debug('p_global_attribute20          : '||p_global_attribute20(i));
        arp_standard.debug('p_created_by                  : '||p_created_by(i));
        arp_standard.debug('p_create_date                 : '||p_create_date(i));
        arp_standard.debug('p_updated_by                  : '||p_updated_by(i));
        arp_standard.debug('p_program_update_date         : '||p_program_update_date(i));
        arp_standard.debug('p_prog_appl_id                : '||p_prog_appl_id(i));
        arp_standard.debug('p_last_update_login           : '||p_last_update_login(i));
        arp_standard.debug('p_conc_program_id             : '||p_conc_program_id(i));
        arp_standard.debug('p_program_update_date         : '||p_program_update_date(i));
        arp_standard.debug('p_set_of_books_id             : '||p_set_of_books_id(i));
        arp_standard.debug('p_gross_unit_selling_price    : '||p_gross_unit_selling_price(i));
        arp_standard.debug('p_gross_extended_amount       : '||p_gross_extended_amount(i));
        arp_standard.debug('p_amount_include_tax_flag     : '||p_amount_include_tax_flag(i));
        arp_standard.debug('p_warehouse_id                : '||p_warehouse_id(i));
        arp_standard.debug('p_translated_description      : '||p_translated_description(i));
        arp_standard.debug('p_taxable_amount              : '||p_taxable_amount(i));
        arp_standard.debug('p_request_id                  : '||p_request_id(i));
        arp_standard.debug('p_extended_acctd_amount       : '||p_extended_acctd_amount(i));
        arp_standard.debug('p_br_ref_customer_trx_id      : '||p_br_ref_customer_trx_id(i));
        arp_standard.debug('p_br_ref_payment_schedule_id  : '||p_br_ref_payment_schedule_id(i));
        arp_standard.debug('p_br_adjustment_id            : '||p_br_adjustment_id(i));
        arp_standard.debug('p_wh_update_date              : '||p_wh_update_date(i));
        arp_standard.debug('org_id                        : '||arp_standard.sysparm.org_id);
        arp_standard.debug('EXCEPTION:  bulk_insert_trx_lines()');
        RAISE;

  END;
END AR_BLK_INSRT_TRX_LINE;


/
