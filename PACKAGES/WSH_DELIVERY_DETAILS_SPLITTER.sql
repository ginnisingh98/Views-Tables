--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_SPLITTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_SPLITTER" AUTHID CURRENT_USER as
/* $Header: WSHDTSPS.pls 120.1.12000000.1 2007/01/25 16:15:23 amohamme noship $ */

  --OTM R12

  PROCEDURE tms_delivery_detail_split
  (p_detail_tab            IN         WSH_ENTITY_INFO_TAB,
   p_item_quantity_uom_tab IN         WSH_UTIL_CORE.COLUMN_TAB_TYPE,
   x_return_status         OUT NOCOPY VARCHAR2);
  --

END WSH_DELIVERY_DETAILS_SPLITTER;


 

/
