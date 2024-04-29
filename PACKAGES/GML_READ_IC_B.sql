--------------------------------------------------------
--  DDL for Package GML_READ_IC_B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_READ_IC_B" AUTHID CURRENT_USER AS
/* $Header: GMLRITMS.pls 115.3 2002/02/05 12:06:39 pkm ship     $ */

FUNCTION read_price_qty_source

(
  p_inventory_item_id IN NUMBER
 ,p_ship_from_org_id  IN NUMBER
)

RETURN NUMBER;

END GML_READ_IC_B;

 

/
