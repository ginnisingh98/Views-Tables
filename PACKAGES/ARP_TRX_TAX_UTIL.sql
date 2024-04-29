--------------------------------------------------------
--  DDL for Package ARP_TRX_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_TAX_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTCTTXS.pls 115.2 2002/11/15 03:33:13 anukumar ship $ */

PROCEDURE get_default_line_num(p_customer_trx_id IN
                                ra_customer_trx_lines.customer_trx_id%type,
                               p_customer_trx_line_id IN
                                ra_customer_trx_lines.customer_trx_line_id%type,
                               p_line_number     OUT NOCOPY
                                 ra_customer_trx_lines.line_number%type );

PROCEDURE get_item_flex_defaults(p_inventory_item_id IN
                                   mtl_system_items.inventory_item_id%type,
                                 p_organization_id IN
                                   mtl_system_items.organization_id%type,
                                 p_trx_date IN
                                   ra_customer_trx.trx_date%type,
                                 p_invoicing_rule_id IN
                                   ra_customer_trx.invoicing_rule_id%type,
                                 p_description OUT NOCOPY
                                   mtl_system_items.description%type,
                                 p_primary_uom_code OUT NOCOPY
                                   mtl_system_items.primary_uom_code%type,
                                 p_primary_uom_name OUT NOCOPY
                                   mtl_units_of_measure.unit_of_measure%type,
                                 p_accounting_rule_id OUT NOCOPY
                                   mtl_system_items.accounting_rule_id%type,
                                 p_accounting_rule_name OUT NOCOPY
                                   ra_rules.name%type,
                                 p_accounting_rule_duration OUT NOCOPY
                                   ra_rules.occurrences%type,
                                 p_accounting_rule_type OUT NOCOPY
                                   ra_rules.type%type,
                                 p_rule_start_date OUT NOCOPY
                                   date );

PROCEDURE select_summary(p_customer_trx_id IN
                           ra_customer_trx_lines.customer_trx_id%type,
                         p_customer_trx_line_id IN number,
                         p_mode            IN varchar2,
                         p_total           IN OUT NOCOPY
                           ra_customer_trx_lines.extended_amount%type,
                         p_total_rtot_db   IN OUT NOCOPY
                           ra_customer_trx_lines.extended_amount%type);

PROCEDURE check_last_line_on_delete(p_customer_trx_line_id IN
                                 ra_customer_trx_lines.customer_trx_line_id%type
,
                                    p_only_tax_line_flag OUT NOCOPY BOOLEAN);

PROCEDURE check_unique_line(p_customer_trx_line_id IN
                                 ra_customer_trx_lines.customer_trx_line_id%type                           ,p_customer_trx_line_num IN
                                 ra_customer_trx_lines.line_number%type,
                            p_unique_line_flag OUT NOCOPY BOOLEAN ) ;
FUNCTION tax_balance(p_prev_cust_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%type,
                     p_cust_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%type )
         RETURN NUMBER;
PROCEDURE check_tax_code(p_tax_code IN
                                 ar_vat_tax.tax_code%type,
                         p_adhoc_tax_flag OUT NOCOPY BOOLEAN ) ;


END ARP_TRX_TAX_UTIL;

 

/
