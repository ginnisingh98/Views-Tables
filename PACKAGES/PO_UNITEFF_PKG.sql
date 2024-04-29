--------------------------------------------------------
--  DDL for Package PO_UNITEFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UNITEFF_PKG" AUTHID CURRENT_USER as
/* $Header: POXPMUES.pls 120.0.12010000.1 2008/09/18 12:21:05 appldev noship $  */


   /* GET_UNIT_NUMBER
    * ---------------
    * This function is called by PO_SHIP_RCV_SUPPLY_VIEW and
    * PO_SHIP_SUPPLY_VIEW.  Given a shipment_line_id and an item id,
    * this function will return the end item unit number that is
    * stored in MTL_SERIAL_NUMBERS.
    */
   FUNCTION GET_UNIT_NUMBER(p_shipment_line_id NUMBER, p_item_id NUMBER)
      RETURN VARCHAR2;


--   PRAGMA RESTRICT_REFERENCES(get_unit_number, WNDS, WNPS, RNPS);



END PO_UNITEFF_PKG;

/
