--------------------------------------------------------
--  DDL for Package ARP_TRX_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TRX_LINE_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARTCTLTS.pls 120.3.12010000.3 2008/11/21 09:39:53 npanchak ship $ */

FUNCTION derive_last_date_to_cr(
              p_customer_trx_line_id IN number,
              p_last_period_to_cr    IN number,
              p_period_set_name      IN varchar2 DEFAULT NULL) RETURN date;


FUNCTION derive_last_pd_to_cr( p_customer_trx_line_id IN number,
                               p_last_date_to_credit  IN date ) RETURN number;

PROCEDURE get_default_line_num(p_customer_trx_id IN   number,
                               p_line_number     OUT NOCOPY  number );

PROCEDURE get_item_flex_defaults(p_inventory_item_id IN Number,
                                 p_organization_id IN Number,
                                 p_trx_date IN Date,
                                 p_invoicing_rule_id IN Number,
                                 p_description OUT NOCOPY varchar2,
                                 p_primary_uom_code OUT NOCOPY varchar2,
                                 p_primary_uom_name OUT NOCOPY varchar2,
                                 p_accounting_rule_id OUT NOCOPY number,
                                 p_accounting_rule_name OUT NOCOPY varchar2,
                                 p_accounting_rule_duration OUT NOCOPY number,
                                 p_accounting_rule_type OUT NOCOPY varchar2,
                                 p_rule_start_date OUT NOCOPY date,
                                 p_frequency OUT NOCOPY varchar2
                                   );

PROCEDURE get_max_line_number(p_customer_trx_id IN   number,
                           p_line_number   OUT NOCOPY  number );

FUNCTION get_oe_header_id(p_oe_line_id        IN  VARCHAR2,
                          p_interface_context IN  VARCHAR2 ) RETURN NUMBER;

FUNCTION get_tax_classification_code(p_vat_tax_id IN Number) RETURN VARCHAR2;

FUNCTION get_tax_amount(p_customer_trx_id IN NUMBER,
			p_tax_type IN VARCHAR2) RETURN NUMBER;

FUNCTION get_tax_amount(p_customer_trx_id IN NUMBER,
                        p_customer_trx_line_id IN NUMBER,
			p_tax_type IN VARCHAR2) RETURN NUMBER;

END ARP_TRX_LINE_UTIL;

/
