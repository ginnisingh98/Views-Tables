--------------------------------------------------------
--  DDL for Package Body PO_UNITEFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UNITEFF_PKG" as
/* $Header: POXPMUEB.pls 120.0.12010000.1 2008/09/18 12:21:07 appldev noship $ */


   /* GET_UNIT_NUMBER
    * ---------------
    * This function is called by PO_SHIP_RCV_SUPPLY_VIEW and
    * PO_SHIP_SUPPLY_VIEW.  Given a shipment line id and an item id,
    * this function will return the end item unit number that is
    * stored in MTL_SERIAL_NUMBERS.
    */
   FUNCTION GET_UNIT_NUMBER(p_shipment_line_id NUMBER, p_item_id NUMBER)
   RETURN VARCHAR2 IS
      v_end_item_unit_number VARCHAR2(30) := NULL;
   BEGIN

      -- The design requires that an intransit shipment can only have
      -- a single unit number.  Hence, a distinct is used in the select
      -- clause here.  We obtain the serial number by mapping to the
      -- RCV_SERIALS_SUPPLY table using the shipment_line_id.
      -- Example: a shipment line contains an item of quantity 9.
      --          Each of the 9 items have a different serial number.
      --          However, all of these 9 items should only have a
      --          single unit number.
      -- If the distinct fails, we will return a NULL.  The intransit
      -- shipment form should NOT allow this to occur in the first place.

      SELECT DISTINCT msn.end_item_unit_number
        INTO v_end_item_unit_number
        FROM mtl_serial_numbers msn,
             rcv_serials_supply rss
       WHERE msn.serial_number = rss.serial_num
         AND rss.shipment_line_id = p_shipment_line_id
         AND msn.inventory_item_id = p_item_id;

      RETURN(v_end_item_unit_number);


   EXCEPTION

      WHEN NO_DATA_FOUND THEN
         RETURN(to_char(NULL));
      WHEN OTHERS THEN
         RETURN(to_char(NULL));

   END GET_UNIT_NUMBER;


END PO_UNITEFF_PKG;

/
