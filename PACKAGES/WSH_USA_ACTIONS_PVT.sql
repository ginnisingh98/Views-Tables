--------------------------------------------------------
--  DDL for Package WSH_USA_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_USA_ACTIONS_PVT" AUTHID CURRENT_USER as
/* $Header: WSHUSAAS.pls 120.0.12010000.2 2009/10/12 09:58:51 brana ship $ */

TYPE Split_Table_Type is RECORD (
        source_line_id  NUMBER ,
        original_source_line_id  NUMBER ,
        changed_Attributes_index NUMBER ,
        direction_flag           VARCHAR2(1) default 'F' ,
        date_requested           DATE );

TYPE Split_Table_Tab_Type IS TABLE OF Split_Table_Type
  INDEX BY BINARY_INTEGER;

--bugfix 8915868 added record structure

TYPE Cancel_Reservation_Table_Type is RECORD (
        source_code        wsh_delivery_details.source_code%type,
	source_header_id    NUMBER,
        source_line_id      NUMBER,
	delivery_detail_id  NUMBER,
        organization_id     NUMBER,
	cancelled_quantity  NUMBER,
        cancelled_quantity2 NUMBER
       );

TYPE Cancel_Reservation_Tab_Type IS TABLE OF Cancel_Reservation_Table_Type
INDEX BY BINARY_INTEGER;

TYPE direction_flag_tab_type  IS TABLE OF VARCHAR2(1)
  INDEX BY BINARY_INTEGER;


CURSOR c_check_ship_sets (c_p_set_id NUMBER,
                            c_p_source_header_id NUMBER) IS -- 2373131
  select wdd.ship_set_id from
  wsh_delivery_details wdd where
  wdd.ship_set_id = c_p_set_id and
  wdd.source_code = 'OE' and
  wdd.source_header_id = c_p_source_header_id and
  ((wdd.released_status = 'C') or exists (select wda.delivery_detail_id
                                     from   wsh_delivery_assignments_v wda, wsh_new_deliveries wnd
                                     where  wda.delivery_detail_id = wdd.delivery_detail_id
                                     and    wda.delivery_id = wnd.delivery_id
                                     and    wnd.status_code in ('CO', 'IT', 'CL', 'SR', 'SC')))
  AND rownum = 1;

--
--  Procedure:          Import_Records
--  Parameters:
--               p_source_code         source system of records to import
--               p_changed_attributes  list of records to process
--               x_return_status       return status
--
--  Description:
--               Import source lines where action_flag = 'I'
--
PROCEDURE Import_Records(
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  x_return_status          OUT NOCOPY            VARCHAR2);


--
--  Procedure:          Split_Records
--  Parameters:
--               p_source_code         source system of records to split
--               p_changed_attributes  list of records to process
--               p_interface_flag      flag identifying the session
--                                     'Y' - called during OM Interface,
--                                     'N' - normal session
--               x_return_status       return status
--
--  Description:
--               Determine whether the call is initated by OM Interface
--               or a normal process.
--               Then split the records accordingly where action_flag = 'S'.
--
PROCEDURE Split_Records(
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  p_interface_flag         IN            VARCHAR2,
  x_return_status          OUT NOCOPY            VARCHAR2);


--
--  Procedure:          Update_Records
--  Parameters:
--               p_source_code         source system of records to update
--               p_changed_attributes  list of records to process
--               p_interface_flag      flag identifying the session
--                                     'Y' - called during OM Interface,
--                                     'N' - normal session
--               x_return_status       return status
--
--  Description:
--               Based on p_interface_flag and action_flag,
--               check attributes being changed
--               and calls Update_Attributes to update the delivery details
--               with the new values.
--
PROCEDURE Update_Records(
  p_source_code            IN            VARCHAR2,
  p_changed_attributes     IN            WSH_INTERFACE.ChangedAttributeTabType,
  p_interface_flag         IN            VARCHAR2,
  x_return_status          OUT NOCOPY            VARCHAR2);


--  Procedure:          Update_Attributes
--  Parameters:
--               p_source_code         source system to update
--               p_attributes_rec      record of attributes to change
--               p_changed_detail      Detail record of attributes to change
--               x_return_status       return status
--  Description:
--               Maps the attributes to shipping values as needed
--               and updates WSH_DELIVERY_DETAILS
--
PROCEDURE Update_Attributes(
  p_source_code       IN        VARCHAR2,
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_changed_detail    IN        WSH_USA_CATEGORIES_PVT.ChangedDetailRec,
  x_return_status     OUT NOCOPY        VARCHAR2);



--  Procedure:      Import_Delivery_Details
--  Parameters:
--                p_source_line_id   source line to import
--                                   if NULL, import all source lines
--                p_source_code      must be 'OE' (Order Management)
--                x_return_status    return status
--
--  Description:    Pulls source line to create new delivery details
--
PROCEDURE Import_Delivery_Details(
  p_source_line_id    IN   NUMBER,
  p_source_code       IN   VARCHAR2,
  x_return_status     OUT NOCOPY   VARCHAR2);


END WSH_USA_ACTIONS_PVT;

/
