--------------------------------------------------------
--  DDL for Package INV_SERIAL_NUMBER_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SERIAL_NUMBER_ATTR" AUTHID CURRENT_USER AS
/* $Header: INVSATRS.pls 115.1 2004/01/26 19:36:11 yssingh noship $ */

---------------------------------------------------------------------------------------------
--This API is created for bug 3303197. After the serial range enhancement, serial numbers are
--not stored on the wsh_delivery_details(WDD) table after pick confirm. Hence, users does not
--have serial number information on WDD. ATT uses WDD attributes to identify the serials
--being shipped. Now, since WDD does not have serials, ct will have to use serial number
--attributes for this purpose. This API will fulfill ct's requirement of populating serial
--attributes in mtl_serial_numbers table during pick release process.
--
--Name : validate_update_serial_attr
--
--Desc : procedure to update serial attributes in the mtl_serial_numbers table
--Input: p_serial_number      - Serial Number
--       p_inventory_item_id  - Inventory Item id
--       p_attributes_tbl     - Table of enabled serial attributes
--       p_attribute_category - Attribute category(Optional) for valueset validations
---------------------------------------------------------------------------------------------

TYPE char_table IS TABLE OF VARCHAR2(500)
  INDEX BY BINARY_INTEGER;

g_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

procedure Update_Serial_number_attr(
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2,

   p_serial_number             IN   VARCHAR2,
   p_inventory_item_id         IN   NUMBER,
   p_attribute_category        IN   VARCHAR2  DEFAULT NULL,
   p_attributes_tbl            IN   inv_serial_number_attr.char_table);

END INV_SERIAL_NUMBER_ATTR;

 

/
