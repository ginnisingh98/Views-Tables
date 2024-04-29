--------------------------------------------------------
--  DDL for Package Body AR_TRX_BULK_PROCESS_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TRX_BULK_PROCESS_LINES" AS
/* $Header: ARINBLLB.pls 120.9 2006/04/17 18:33:36 mraymond noship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE INSERT_ROW(
    p_trx_header_id         IN      NUMBER,
    p_trx_line_id           IN      NUMBER,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2 )  IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_BULK_PROCESS_LINES.INSERT_ROW (+)');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        INSERT INTO ra_customer_trx_lines
            (
                customer_trx_line_id,
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
                accounting_rule_id,
                rule_start_date,
                autorule_complete_flag,
                autorule_duration_processed,
                reason_code,
                last_period_to_credit,
                sales_order,
                sales_order_date,
                sales_order_line,
                sales_order_source,
                vat_tax_id,
                tax_exempt_flag,
                location_segment_id,
                tax_exempt_number,
                tax_exempt_reason_code,
                tax_vendor_return_code,
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
                payment_set_id,
                org_id,
                override_auto_accounting_flag,
		accounting_rule_duration, /*Bug 4161915*/
                rule_end_date,
                HISTORICAL_FLAG,
                TAXABLE_FLAG,
                TAX_CLASSIFICATION_CODE,
                interest_line_id
                )
                Select
                customer_trx_line_id, --RA_CUSTOMER_TRX_LINES_S.NEXTVAL,
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
                null,--initial_customer_trx_line_id,
                link_to_cust_trx_line_id,
                null, --previous_customer_trx_id,
                null, --previous_customer_trx_line_id,
                accounting_rule_id,
                rule_start_date,
                autorule_complete_flag,
                autorule_duration_processed,
                reason_code,
                last_period_to_credit,
                sales_order,
                sales_order_date,
                sales_order_line,
                sales_order_source,
                vat_tax_id,
                tax_exempt_flag,
                location_segment_id,
                tax_exempt_number,
                tax_exempt_reason_code,
                tax_vendor_return_code,
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
                fnd_global.user_id, --  created_by
                sysdate,                          /* creation_date */
                fnd_global.user_id, 		/* last_updated_by */
                sysdate,				/* last_update_date */
                fnd_global.prog_appl_id, /* program_application_id */
                fnd_global.login_id,	/* last_update_login */
                null,		/* program_id */
                sysdate,				/* program_update_date */
                set_of_books_id,	/* set_of_books_id */
                gross_unit_selling_price,
                gross_extended_amount,
                amount_includes_tax_flag,
                warehouse_id,
                null, --translated_description,
                taxable_amount,
                request_id, --request_id,
                extended_acctd_amount,
                null, --br_ref_customer_trx_id,
                null, --br_ref_payment_schedule_id,
                null, --br_adjustment_id,
                null, --wh_update_date,
                null, --payment_set_id
                arp_standard.sysparm.org_id,
                override_auto_accounting_flag,
		accounting_rule_duration , /*Bug 4161915*/
                rule_end_date,
                NVL(HISTORICAL_FLAG,'N'),
                TAXABLE_FLAG,
                TAX_CLASSIFICATION_CODE,
                interest_line_id
                FROM ar_trx_lines_gt
                WHERE  trx_header_id = nvl(p_trx_header_id, trx_header_id)
                AND    trx_line_id  = nvl(p_trx_line_id, trx_line_id);

    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_TRX_BULK_PROCESS_LINES.INSERT_ROW (-)');
    END IF;


    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_TRX_BULK_PROCESS_LINES.INSERT_ROW '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;

END INSERT_ROW;
END AR_TRX_BULK_PROCESS_LINES;

/