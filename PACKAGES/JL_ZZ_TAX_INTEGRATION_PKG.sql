--------------------------------------------------------
--  DDL for Package JL_ZZ_TAX_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_TAX_INTEGRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzztins.pls 120.2.12010000.2 2008/08/04 12:53:28 vgadde ship $ */

-- Bug#6936808
g_jl_exception_type        VARCHAR2(1);

PROCEDURE populate_om_ar_tax_struct
     (p_conversion_rate    IN NUMBER,
      p_currency_code      IN VARCHAR2,
      p_fob_point_code     IN VARCHAR2,
      p_global_attribute5  IN VARCHAR2,
      p_line_id            IN NUMBER,
      p_header_id          IN NUMBER,
      p_inventory_item_id  IN NUMBER,
      p_invoice_to_org_id  IN NUMBER,
      p_invoicing_rule_id  IN NUMBER,
      p_line_type_id       IN NUMBER,
      p_pricing_quantity   IN NUMBER,
      p_payment_term_id    IN NUMBER,
      p_global_attribute6  IN VARCHAR2,
      p_ship_from_org_id   IN NUMBER,
      p_ship_to_org_id     IN NUMBER,
      p_tax_code           IN VARCHAR2,
      p_tax_date           IN DATE,
      p_tax_exempt_flag    IN VARCHAR2,
      p_tax_exempt_number  IN VARCHAR2,
      p_tax_exempt_reason  IN VARCHAR2,
      p_unit_selling_price IN NUMBER,
      p_org_id             IN NUMBER);  --Bug fix 2367111

PROCEDURE populate_ship_bill2
     (p_ship_to_site_use_id IN NUMBER,
      p_bill_to_site_use_id IN NUMBER,
      p_ship_to_cust_id     IN NUMBER DEFAULT NULL,
      p_bill_to_cust_id     IN NUMBER DEFAULT NULL);

PROCEDURE expand_group_tax_code
     (p_org_id IN NUMBER);  --Bug fix 2367111

END JL_ZZ_TAX_INTEGRATION_PKG;

/
