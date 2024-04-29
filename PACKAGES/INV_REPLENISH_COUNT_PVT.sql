--------------------------------------------------------
--  DDL for Package INV_REPLENISH_COUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_REPLENISH_COUNT_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVVRPCS.pls 120.0 2005/05/25 05:43:52 appldev noship $*/

  /**
   *  Package     : INV_REPLENISH_COUNT_PVT <br>
   *  File        : INVVRPCS.pls            <br>
   *  Content     :                         <br>
   *  Description :                         <br>
   *  Notes       :
   *  Modified    : Mon Aug 25 12:17:54 GMT+05:30 2003 <br>
   *
   *  Package Specification for INV_REPLENISH_COUNT_PVT.<br>
   *  This file contains procedures and functions needed for
   *  Replenishment Count being used in the mobile WMS/INV applications.<br>
   *  This package also includes APIs to process and report Count entries
   *  for a Replenishment Count.<b>
  **/

  TYPE t_genref IS REF CURSOR;
  /**
   *  This Procedure is used to insert values into table mtl_replenish_lines<p>
   *  @param    x_return_status         Return Status<br>
   *  @param    x_msg_count             Message Count<br>
   *  @param    x_msg_data              Message Data<br>
   *  @param    p_organization_id       Organization Id<br>
   *  @param    p_replenish_header_id   Replenishment Count Header Id<br>
   *  @param    p_locator_id            Locator Id<br>
   *  @param    p_item_id               Item ID<br>
   *  @param    p_count_type_code       Count Type Code<br>
   *  @param    p_count_quantity        Count Quantity<br>
   *  @param    p_count_uom_code        Count Uom Code<br>
   *  @param    p_primary_uom_code      Primary Uom Code <br>
   *  @param   p_count_secondary_uom_code  Secondary Uom Code<br>
   *  @param   p_count_secondary_quantity  Secondary Quantity<br>
   **/
  PROCEDURE insert_row(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , p_organization_id     IN NUMBER
  , p_replenish_header_id IN NUMBER
  , p_locator_id          IN NUMBER
  , p_item_id             IN NUMBER
  , p_count_type_code     IN NUMBER
  , p_count_quantity      IN NUMBER
  , p_count_uom_code      IN VARCHAR2
  , p_primary_uom_code    IN VARCHAR2
  , p_count_secondary_uom_code IN            VARCHAR2  -- INVCONV, NSRIVAST
  , p_count_secondary_quantity IN            NUMBER    -- INVCONV, NSRIVAST
  );

  /**
   *  This Procedure is used to update table mtl_replenish_lines.<p>
   *  @param    x_return_status         Return Status<br>
   *  @param    x_msg_count             Message Count<br>
   *  @param    x_msg_data              Message Data<br>
   *  @param    p_item_id               Item ID<br>
   *  @param    p_replenish_header_id   Replenishment Count Header Id<br>
   *  @param    p_replenish_line_id     Replenishment Count Line Id
   *  @param    p_count_quantity        Count Quantity<br>
   *  @param    p_primary_uom_code      Primary Uom Code<br>
   *  @param   p_count_secondary_quantity  Secondary Quantity<br>
   **/
  PROCEDURE update_row(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , p_item_id             IN NUMBER
  , p_replenish_header_id IN NUMBER
  , p_replenish_line_id   IN NUMBER
  , p_count_quantity      IN NUMBER
  , p_count_uom_code      IN VARCHAR2
  , p_count_secondary_quantity IN            NUMBER    -- INVCONV, NSRIVAST
  );

  /** This Procedure is used to fetch the Replenishment Count lines for the user input.<p>
   *  @param   x_return_status               Return Status<br>
   *  @param   x_msg_count                   Message Count<br>
   *  @param   x_msg_data                    Message Data<br>
   *  @param   x_replenish_count_lines_lov   Replenish Count Lines LOV<br>
   *  @param   p_replenish_header_id         Replenishment Header Id<br>
   *  @param   p_use_loc_pick_seq            Use Locator Picking Sequence or not<br>
   *  @param   p_organization_id             Organization Id<br>
   *  @param   p_subinventory_code           Subinventory Code<br>
   *  @param   p_planning_level              Planning level of the subinventory<br>
   *  @param   p_quantity_tracked            Qauntity Tracked Flag of the Subinventory
   **/
  PROCEDURE fetch_count_lines(
    x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , x_replenish_count_lines OUT NOCOPY t_genref
  , p_replenish_header_id   IN NUMBER
  , p_use_loc_pick_seq      IN VARCHAR2
  , p_organization_id       IN NUMBER
  , p_subinventory_code     IN VARCHAR2
  , p_planning_level        IN NUMBER
  , p_quantity_tracked      IN NUMBER
  );

  /** This procedure is used to get the Replenishment Count Name if the Subinventory and Organization passed
   *  as input has only one active Replenishment Count.<p>
   *  @param    x_return_status         Return Status<br>
   *  @param    x_msg_count             Message Count<br>
   *  @param    x_msg_data              Message Data<br>
   *  @param    x_replenish_count_name  Replenishment Count Name for the Subinventory and Organization passed<br>
   *                                    if there exists only obe active Replenishment Count.<br>
   *                                    NULL - Otherwise.<br>
   *  @param    p_organization_id       Organization ID<br>
   *  @param    p_subinventory_code     Subinventory Code<br>
   *  @param    p_planning_level        Subinventory Planning Level<br>
  **/
  PROCEDURE get_replenish_count_name(
    x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , x_replenish_count_name OUT NOCOPY    VARCHAR2
  , p_organization_id      IN            NUMBER
  , p_subinventory_code    IN            VARCHAR2
  , p_planning_level       IN            NUMBER
  );

  /** This procedure is used to check whether invalid and/or uncounted lines exist.<p>
   *  @param    x_return_status         Return Status<br>
   *  @param    x_msg_count             Message Count<br>
   *  @param    x_msg_data              Message Data<br>
   *  @param    p_replenish_header_id   Replenishment Count Header Id<br>
   *  @param    p_quantity_tracked      Qauntity Tracked Flag of the Subinventory<br>
   *  @param    p_planning_level        Planning level of the subinventory<br>
   *  @param    p_subinventory_code     Subinventory Code<br>
   *  @RETURN   NUMBER                  1 - Invalid and uncounted lines exist.<br>
   *                                    2 - Invalid but no uncounted lines exist.<br>
   *                                    3 - No invalid but uncounted lines exist.<br>
   *                                    4 - No invalid and no uncounted lines exist.<br>
  **/
  FUNCTION invalid_uncounted_lines_exist(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , p_replenish_header_id IN NUMBER
  , p_quantity_tracked IN NUMBER
  , p_planning_level IN NUMBER
  , p_subinventory_code IN VARCHAR2
  )
    RETURN NUMBER;

  /** This function returns if the Replenishment Count passed as input is a valid
   *  one for the passed subinventory planning level.<p>
   *  @param    x_return_status         Return Status<br>
   *  @param    x_msg_count             Message Count<br>
   *  @param    x_msg_data              Message Data<br>
   *  @param    p_replenish_header_id   Replenishment Count Header Id<br>
   *  @param    p_planning_level        Subinventory Planning Level<br>
   *  @RETURN   NUMBER                  1 - Count is valid.<br>
   *                                    2 - Count is invalid.<br>
  **/
  FUNCTION is_count_valid(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_replenish_header_id IN            NUMBER
  , p_planning_level      IN            NUMBER
  )
    RETURN NUMBER;

  /** This procedure submits the passed in Replenishment Count
   *  for processing and Report.<p>
   *  @param    x_return_status         Return Status<br>
   *  @param    x_msg_count             Message Count<br>
   *  @param    x_msg_data              Message Data<br>
   *  @param    x_proces_request_id     Process Request Id<br>
   *  @param    p_replenish_header_id   Replenishment Count Header Id<br>
   *  @param    p_organization_id       Organization Id<br>
   **/
  PROCEDURE process_report_count(
    x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_process_request_id  OUT NOCOPY NUMBER
  , p_replenish_header_id IN NUMBER
  , p_organization_id     IN NUMBER
  );
END inv_replenish_count_pvt;

 

/
