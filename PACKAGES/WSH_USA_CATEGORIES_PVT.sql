--------------------------------------------------------
--  DDL for Package WSH_USA_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_USA_CATEGORIES_PVT" AUTHID CURRENT_USER as
/* $Header: WSHUSACS.pls 120.0.12000000.1 2007/01/16 05:52:19 appldev ship $ */


TYPE ChangedDetailRec IS RECORD(

  EARLIEST_PICKUP_DATE  WSH_DELIVERY_DETAILS.EARLIEST_PICKUP_DATE%TYPE,
  LATEST_PICKUP_DATE  WSH_DELIVERY_DETAILS.LATEST_PICKUP_DATE%TYPE,
  EARLIEST_DROPOFF_DATE  WSH_DELIVERY_DETAILS.EARLIEST_DROPOFF_DATE%TYPE,
  LATEST_DROPOFF_DATE  WSH_DELIVERY_DETAILS.LATEST_DROPOFF_DATE%TYPE

);


--
--  Procedure:          Check_Attributes
--  Parameters:
--               p_source_code         source code to update
--               p_attributes_rec      record of attributes to change
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--               Calls Change_xxx APIs to check the attributes being updated.
PROCEDURE Check_Attributes(
  p_source_code       IN   VARCHAR2,
  p_attributes_rec    IN   WSH_INTERFACE.ChangedAttributeRecType,
  x_changed_detail    OUT NOCOPY WSH_USA_CATEGORIES_PVT.ChangedDetailRec,
  x_update_allowed    OUT NOCOPY   VARCHAR2,
  x_return_status     OUT NOCOPY   VARCHAR2);


--
--  Procedure:         Change_Quantity
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               p_wms_flag            indicates if source line is in WMS org (Y-yes, N-no)
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--               x_update_allowed is set to 'N' if the changes are not allowed.
--               The caller is responsible for initializing x_update_allowed = 'Y'.
--
--  Description:
--               Checks for Change in Quantity and do actions as needed.


PROCEDURE Change_Quantity(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);

--
--  Procedure:          Change_Schedules
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               p_wms_flag            indicates if source line is in WMS org (Y-yes, N-no)
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--               Checks for attribute changes that will trigger lines to change schedules and
--               become "Ready to Release."
--               x_update_allowed is set to 'N' if the changes are not allowed.
--               The caller is responsible for initializing x_update_allowed = 'Y'.

PROCEDURE Change_Schedule(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);

--
--  Procedure:         Change_Scheduled_Date
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               p_wms_flag            indicates if source line is in WMS org (Y-yes, N-no)
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--               Checks for attributes that will change the scheduled date and may cause the
--               system to Log Exception.
--               x_update_allowed is set to 'N' if the changes are not allowed.
--               The caller is responsible for initializing x_update_allowed = 'Y'.

PROCEDURE Change_Scheduled_Date(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);

--
--  Procedure:         Change_Sets
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               p_wms_flag            indicates if source line is in WMS org (Y-yes, N-no)
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--               Checks Ship Set changes.
--               x_update_allowed is set to 'N' if the changes are not allowed.
--               The caller is responsible for initializing x_update_allowed = 'Y'.

PROCEDURE Change_Sets(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);

--
--  Procedure:         Change_Delivery_Group
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               p_wms_flag            indicates if source line is in WMS org (Y-yes, N-no)
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--               Checks for Delivery Grouping Attributes and do actions as needed.
--               x_update_allowed is set to 'N' if the changes are not allowed.
--               The caller is responsible for initializing x_update_allowed = 'Y'.

PROCEDURE Change_Delivery_Group(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);

-- anxsharm
-- Bug 2181132
--
--  Procedure:         Change_Ship_Tolerance
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               p_wms_flag            indicates if source line is in WMS org (Y-yes, N-no)
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--               Checks if Tolerance is being modified for any delivery line
--               in a line set. If any of the delivery line within the line
--               set is staged or shipped, then reject tolerance changes.
--               x_update_allowed is set to 'N' if the changes are not allowed.
--               The caller is responsible for initializing x_update_allowed = 'Y'.

PROCEDURE Change_Ship_Tolerance(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);


-- anxsharm
--  Procedure:         Change_TP_Dates
--  Parameters:
--               p_attributes_rec      record of attributes to change
--               x_update_allowed      flag to indicate if the delivery lines can be updated
--                                        'Y' - update is allowed, 'N' - update is disallowed
--               x_return_status       return status
--
--  Description:
--        Calculates the TPdates for the delivery detail. If the detail dates are changed
--        The deliveries and container of the detail line is updated with new Tpdates.
PROCEDURE Change_TP_Dates(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
  p_source_code       IN        VARCHAR2,
  x_changed_detail    OUT NOCOPY WSH_USA_CATEGORIES_PVT.ChangedDetailRec,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2);


END WSH_USA_CATEGORIES_PVT;

 

/
