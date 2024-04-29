--------------------------------------------------------
--  DDL for Package OE_ORDER_MISC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_MISC_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXMISCS.pls 120.1 2006/05/25 08:00:28 pkannan noship $ */

-- Bug 5244726
PROCEDURE GET_ITEM_INFO
(   x_return_status         OUT NOCOPY VARCHAR2
,   x_msg_count             OUT NOCOPY NUMBER
,   x_msg_data              OUT NOCOPY VARCHAR2
,   p_item_identifier_type          IN VARCHAR2
,   p_inventory_item_id             IN Number
,   p_ordered_item_id               IN Number
,   p_sold_to_org_id                IN Number
,   p_ordered_item                  IN VARCHAR2
,   x_ordered_item          OUT NOCOPY VARCHAR2
,   x_ordered_item_desc     OUT NOCOPY VARCHAR2
,   x_inventory_item        OUT NOCOPY VARCHAR2
,   p_org_id                        IN Number DEFAULT NULL
);


Function convert_uom
(
  p_item_id   	in  number,
  p_from_uom_code in  varchar2,
  p_to_uom_code   in  varchar2,
  p_from_qty  	in  number
) return number;

end OE_Order_Misc_Util;

 

/
