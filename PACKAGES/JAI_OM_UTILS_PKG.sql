--------------------------------------------------------
--  DDL for Package JAI_OM_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OM_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_om_utils.pls 120.2 2006/03/27 14:24:57 hjujjuru ship $ */

gd_ass_value_date CONSTANT DATE DEFAULT SYSDATE ;  --Added rpokkula for  File.Sql.35

procedure get_ato_pricelist_value
(
 NEW_LIST NUMBER,
 UNIT_CODE NUMBER,
 INVENTORY_ID NUMBER,
 IL6 NUMBER,
 NAMOUNT OUT NOCOPY NUMBER
);

function get_oe_assessable_value
(
  p_customer_id IN NUMBER,
  p_ship_to_site_use_id IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_uom_code IN VARCHAR2,
  p_default_price IN NUMBER,
  p_ass_value_date IN DATE,    --DEFAULT SYSDATE -- Added global variable gd_ass_value_date in package spec. by rpokkula for File.Sql.35
  /* Bug 5096787. Added the following parameters */
  p_sob_id           IN NUMBER   ,
  p_curr_conv_code   IN VARCHAR2 ,
  p_conv_rate        IN NUMBER
)
RETURN NUMBER ;

procedure get_ato_assessable_value
(
  NEW_ASSESS_LIST NUMBER,
  IL6 NUMBER ,
  NAMOUNT OUT NOCOPY NUMBER
);

function validate_excise_exemption
(
  p_line_id                   JAI_OM_OE_SO_LINES.LINE_ID%TYPE               ,
  p_excise_exempt_type        JAI_OM_OE_SO_LINES.EXCISE_EXEMPT_TYPE%TYPE    ,
  p_line_number               JAI_OM_OE_SO_LINES.LINE_NUMBER%TYPE           ,
  p_shipment_line_number      JAI_OM_OE_SO_LINES.SHIPMENT_LINE_NUMBER%TYPE  ,
  p_error_msg       OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2 ;

END jai_om_utils_pkg;
 

/
