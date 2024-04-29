--------------------------------------------------------
--  DDL for Package INV_RCV_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RCV_CACHE" AUTHID CURRENT_USER AS
/* $Header: INVRCSHS.pls 120.1.12010000.2 2010/05/20 09:38:24 skommine ship $*/

TYPE to_uom_code_tb IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
TYPE from_uom_code_tb IS TABLE OF to_uom_code_tb INDEX BY VARCHAR2(3);
TYPE item_uom_conversion_tb IS TABLE OF from_uom_code_tb INDEX BY BINARY_INTEGER;

TYPE item_attributes IS RECORD
  ( primary_uom_code            VARCHAR2(3)
    ,secondary_uom_code         VARCHAR2(3)
    ,lot_control_code           NUMBER
    ,serial_number_control_code NUMBER);

TYPE item_attrib_tb IS TABLE OF item_attributes INDEX BY BINARY_INTEGER;
TYPE org_item_attrib_tb IS TABLE OF item_attrib_tb INDEX BY BINARY_INTEGER;

g_org_item_attrib_tb org_item_attrib_tb;
g_item_uom_conversion_tb   item_uom_conversion_tb;
g_conversion_precision CONSTANT NUMBER := 5;

FUNCTION convert_qty
  (p_inventory_item_id   IN NUMBER
   ,p_from_qty           IN NUMBER
   ,p_from_uom_code      IN VARCHAR2
   ,p_to_uom_code        IN VARCHAR2
   ,p_precision          IN NUMBER DEFAULT NULL
   , p_organization_id   IN NUMBER DEFAULT NULL  --Bug#9570776
   , p_lot_number        IN VARCHAR2 DEFAULT NULL  --Bug#9570776
   )
  RETURN NUMBER;

FUNCTION get_primary_uom_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   )
  RETURN VARCHAR2;

FUNCTION get_secondary_uom_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   )
  RETURN VARCHAR2;

FUNCTION get_sn_ctrl_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   )
  RETURN NUMBER;

FUNCTION get_lot_control_code
  (p_organization_id     IN NUMBER
   ,p_inventory_item_id  IN NUMBER
   )
  RETURN NUMBER;

FUNCTION get_conversion_rate
  (p_inventory_item_id   IN NUMBER
   ,p_from_uom_code      IN VARCHAR2
   ,p_to_uom_code        IN VARCHAR2
   )
  RETURN NUMBER;

END inv_rcv_cache;

/
