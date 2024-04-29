--------------------------------------------------------
--  DDL for Package JAI_OM_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OM_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_om_tax.pls 120.2 2007/06/15 05:09:14 bduvarag ship $ */

procedure calculate_ato_taxes
(
  transaction_name VARCHAR2,
  P_tax_category_id NUMBER,
  p_header_id NUMBER,
  p_line_id NUMBER,
  p_assessable_value NUMBER default 0,
  p_tax_amount IN OUT NOCOPY NUMBER,
  p_currency_conv_factor NUMBER,
  p_inventory_item_id NUMBER,
  p_line_quantity NUMBER,
  p_quantity NUMBER,
  p_uom_code VARCHAR2,
  p_vendor_id NUMBER,
  p_currency VARCHAR2,
  p_creation_date DATE,
  p_created_by NUMBER,
  p_last_update_date DATE,
  p_last_updated_by NUMBER,
  p_last_update_login NUMBER,
  p_vat_assessable_Value NUMBER DEFAULT 0 ,
  p_vat_reversal_price NUMBER DEFAULT 0/*Bug#6072461, bduvarag*/
);

procedure recalculate_oe_taxes
(
  p_header_id     IN NUMBER,
  p_line_id     IN NUMBER,
  p_assessable_value  IN NUMBER DEFAULT 0,
  p_vat_assess_value      IN NUMBER,
  p_tax_amount    IN OUT NOCOPY NUMBER,
  p_inventory_item_id IN NUMBER,
  p_line_quantity   IN NUMBER,
  p_uom_code      IN VARCHAR2,
  p_currency_conv_factor IN NUMBER,
  p_last_updated_date IN DATE,
  p_last_updated_by   IN NUMBER,
  p_last_update_login IN NUMBER
);

PROCEDURE recalculate_excise_taxes
(   errbuf     OUT NOCOPY VARCHAR2
  , retcode    OUT NOCOPY VARCHAR2
  , pn_org_id             NUMBER
  , pn_start_order        NUMBER
  , pn_end_order          NUMBER
  , pn_order_type_id      NUMBER
  , pn_ship_from_org_id   NUMBER
 );

END jai_om_tax_pkg;

/
