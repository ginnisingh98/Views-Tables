--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_UTIL" AUTHID CURRENT_USER as
--$Header: JMFUSHKS.pls 120.9 2006/09/20 10:59:32 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFUSHKS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Package specification file for the Utility package |
--|                        of the Charge Based SHIKYU project.                |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   29-APR-2005          vchu  Created.                                     |
--|   28-SEP-2005          vchu  Modified signature of the                    |
--|                              Get_Shikyu_Component_Price procedure         |
--|   03-OCT-2005           shu  Added the debug_output procedure             |
--|   21-OCT-2005          vchu  Added the Get_Shikyu_Offset_Account          |
--|                              procedure                                    |
--|   26-JUN-2005        nesoni  Function Get_Replenish_So_Returned_Qty is    |
--|                              modified                                     |
--|   30-AUG-2006      rajkrish  Added a new procedure to clean up invalid    |
--|                              data                                         |
--|   08-SEP-2006          vchu  Added the new function To_Xsd_Date_String    |
--|                              to convert date values into XSD format so    |
--|                              that they can be formatted correctly in XML  |
--|                              Publisher Reports.                           |
--|   19-SEP-2006          vchu  Modified the function To_Xsd_Date_String     |
--|                              to take a second optional parameter that     |
--|                              denotes the timezone of the offset to be     |
--|                              attached to the DateTime string (either      |
--|                              Server or Client).                           |
--|   20-SEP-2006          vchu  Modified the function To_Xsd_Date_String     |
--|                              to take a second optional parameter that     |
--|                              denotes whether the time component of the    |
--|                              Oracle Date should be omitted.  No need for  |
--|                              this function to optionally attach the User  |
--|                              Timezone offset since it has been decided    |
--|                              that UPTZ would not be supported for R12.    |
--+===========================================================================+

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_UTIL';
G_SLEEP_TIME    NUMBER     := 15;

TYPE g_request_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--==============================
-- PROCEDURES/FUNCTIONS
--==============================

--===================================================================
-- PROCEDURE : clean_invalid_data
-- PARAMETERS :
-- COMMENTS : This procedure will clean/freeze the invalid data in the
--            SHIKYu tables if the data is corrupted
--=====================================================================

PROCEDURE clean_invalid_data ;



--========================================================================
-- FUNCTION  : Get_Primary_Uom     PUBLIC
-- PARAMETERS: p_inventory_item_id Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function returns the name of the primary UOM
--             of the item specified by the input parameters
--========================================================================

FUNCTION Get_Primary_Uom
( p_inventory_item_id IN NUMBER
, p_organization_id   IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_Primary_Uom_Code    PUBLIC
-- PARAMETERS: p_inventory_item_id Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function returns the code of the primary UOM
--             of the item specified by the input parameters
--========================================================================

FUNCTION Get_Primary_Uom_Code
( p_inventory_item_id   IN NUMBER
, p_organization_id     IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_Uom_Code       PUBLIC
-- PARAMETERS: p_unit_of_measure  Unit of Measure
-- COMMENT   : This function converts an UOM name to the corresponding
--             UOM code
--========================================================================

FUNCTION Get_Uom_Code
( p_unit_of_measure     IN VARCHAR2
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_Uom_Conversion_Rate	PUBLIC
-- PARAMETERS: p_inventory_item_id Inventory Item
--             p_organization_id   Inventory Organization
-- COMMENT   : This function returns UOM conversion rate
--========================================================================

FUNCTION Get_Uom_Conversion_Rate
( P_from_unit VARCHAR2
, P_to_unit VARCHAR2
, P_item_id NUMBER
)
RETURN NUMBER;

--========================================================================
-- FUNCTION  : Get_Replenish_So_Returned_Qty	PUBLIC
-- PARAMETERS: p_replenishment_so_line_id Replenishment Sales Order line
-- COMMENT   : This function calculates returned quantity in primary
--             UOM against Replenishment Sales Order Line
--========================================================================

FUNCTION Get_Replenish_So_Returned_Qty
( p_replenishment_so_line_id NUMBER
)
RETURN NUMBER;

--========================================================================
-- FUNCTION  : Get_Replenish_So_Received_Qty	PUBLIC
-- PARAMETERS: p_replenishment_so_line_id Replenishment Sales Order line
-- COMMENT   : This function calculates received quantity in TP Org primary
--             UOM against Replenishment Sales Order Line
--========================================================================

FUNCTION Get_Replenish_So_Received_Qty
( p_replenishment_so_line_id IN NUMBER
)
RETURN NUMBER;

-----------------------------------------------------------------------
-- FUNCTION Get_Used_Quantity
-- Comments: This utility will return the component quantity that has been
--           currently issued for WIP job
------------------------------------------------------------------------
FUNCTION Get_Used_Quantity
( p_wip_entity_id              IN NUMBER
, p_shikyu_component_id        IN NUMBER
, p_organization_id            IN NUMBER
)
RETURN NUMBER;

-----------------------------------------------------------------
--- FUNCTION Get_Primary_Quantity
--  Comments: This utility will convert the PO UOM qty into
--            Primary qty
--------------------------------------------------------------------------------
FUNCTION Get_Primary_Quantity
( p_purchasing_UOM     IN VARCHAR2
, p_quantity           IN NUMBER
, P_inventory_org_id   IN NUMBER
, p_inventory_item_id  IN NUMBER
)
RETURN NUMBER;

----------------------------------------------------------------
--FUNCTION Get_Final_Ship_Date
--Comments: This utility returns the ship date with the lead intransit
--          days included
-----------------------------------------------------------------
FUNCTION Get_Final_Ship_Date
( p_oem_organization    IN NUMBER
, p_tp_organization     IN NUMBER
, p_scheduled_ship_date IN DATE
)
RETURN DATE;

----------------------------------------------------------
-- FUNCTION Get_Allocation_Date
-- Comments: This utility returns the allocation need by date
--           based on a WIP entity job
---------------------------------------------------------
FUNCTION Get_Allocation_Date
( p_wip_entity_id IN NUMBER
)
RETURN DATE;

PROCEDURE Get_Subcontract_Order_Org_Ids
( p_subcontract_po_shipment_id NUMBER
, x_oem_organization_id        OUT NOCOPY NUMBER
, x_tp_organization_id         OUT NOCOPY NUMBER
);

--=============================================================================
-- PROCEDURE NAME: To_Xsd_Date_String
-- TYPE          : PUBLIC
-- PARAMETERS    :
--   p_date        Oracle Date to be converted to XSD Date Format
--   p_omit_time   Denotes whether the time component of the Oracle Date
--                 should be omitted
--                 should be for the Server ('S') or Client timezone ('C')
-- RETURN        : A String representing the passed in Date in XSD Date Format
-- DESCRIPTION   : Convert an Oracle DB Date Object to a date string represented
--                 in the XSD Date Format.  This is mainly for use by the
--                 XML Publisher Reports.
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 07-SEP-06    VCHU    Created.
--=============================================================================

FUNCTION To_Xsd_Date_String
( p_date      IN DATE
, p_omit_time IN VARCHAR2 DEFAULT 'N'
)
RETURN VARCHAR2;

PROCEDURE Get_Shikyu_Attributes
( p_organization_id          IN  NUMBER
, p_item_id                  IN  NUMBER
, x_outsourced_assembly      OUT NOCOPY NUMBER
, x_subcontracting_component OUT NOCOPY NUMBER
, p_primary_uom_price        OUT NOCOPY NUMBER
);

PROCEDURE Get_Shikyu_Component_Price
( p_subcontract_po_shipment_id IN  NUMBER
, p_shikyu_component_id        IN  NUMBER
, x_component_uom              OUT NOCOPY VARCHAR2
, x_component_price            OUT NOCOPY NUMBER
, x_primary_uom                OUT NOCOPY VARCHAR2
, x_primary_uom_price          OUT NOCOPY NUMBER
);

PROCEDURE Get_Replen_Po_Allocated_Qty
( p_replen_po_shipment_id IN  NUMBER
, x_allocated_primary_uom_qty OUT NOCOPY NUMBER
, x_primary_uom               OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Replen_Po_Ordered_Qty
( p_replen_po_shipment_id   IN  NUMBER
, x_ordered_primary_uom_qty OUT NOCOPY NUMBER
, x_primary_uom             OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Replen_So_Allocated_Qty
( p_replen_so_line_id         IN  NUMBER
, x_allocated_qty             OUT NOCOPY NUMBER
, x_uom                       OUT NOCOPY VARCHAR2
, x_allocated_primary_uom_qty OUT NOCOPY NUMBER
, x_primary_uom               OUT NOCOPY VARCHAR2
);

-- RETURN the quantity in primary UOM if the actual
-- parameter for p_uom is NULL
FUNCTION Get_Subcontract_Allocated_Qty
( p_subcontract_po_shipment_id IN NUMBER
, p_component_id               IN NUMBER
)
RETURN NUMBER;

PROCEDURE Get_Replenishment_So_Price
( p_replenishment_so_line_id IN  NUMBER
, x_uom                      OUT NOCOPY VARCHAR2
, x_price                    OUT NOCOPY NUMBER
);

--========================================================================
-- PROCEDURE : debug_output    PUBLIC
-- PARAMETERS: p_output_to     Identifier of where to output to
--             p_api_name      Name of the api being called
--             p_message       Output message
-- COMMENT   : For outputting messages to FND Log, Concurrent Request Log
--             or Concurrent Request Output File.
-- PRE-COND  :
-- EXCEPTIONS:
--========================================================================
PROCEDURE debug_output
( p_output_to IN VARCHAR2
, p_api_name  IN VARCHAR2
, p_message   IN VARCHAR2
);

--===========================================================================
--  API NAME   : Get_Shikyu_Offset_Account
--
--  DESCRIPTION:
--
--  PARAMETERS :
--  IN         :
--  OUT        :
--
--  CHANGE HISTORY:	21-Oct-05	VCHU   Created.
--===========================================================================
PROCEDURE Get_Shikyu_offset_Account
( p_po_shipment_id  IN  NUMBER
, x_offset_account  OUT NOCOPY NUMBER
);

/* Batch Processing procedures */

--========================================================================
-- PROCEDURE : Submit_Worker PUBLIC
-- PARAMETERS: p_batch_id            IN NUMBER    Batch reference that identifies set
--                                                of rows to be processed
--             p_request_count       IN NUMBER    Max number of workers allowed
--             p_cp_short_name       IN VARCHAR2  Short name of concurrent program
--             p_cp_product_code     IN VARCHAR2  Owning product of concurrent program
--             x_workers             IN OUT       Table (of type g_request_tbl_type) containing the
--                                                concurrent request IDs of all the active workers
--             x_request_id          OUT NUMBER   It returns Concurrent Request ID which is
--                                                submitted recently.
--             x_return_status       OUT NUMBER   Return Status
-- COMMENT   : This generic procedure is called to submit concurrent requests.
--             It returns a table containing list of active workers. This accepts
--             batch id as one argument to concurrent program.
--========================================================================
PROCEDURE Submit_Worker
( p_batch_id	    IN  NUMBER
, p_request_count	IN  NUMBER
, p_cp_short_name   IN  VARCHAR2
, p_cp_product_code IN  VARCHAR2
, x_workers	    IN  OUT NOCOPY g_request_tbl_type
, x_request_id      OUT NOCOPY NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
);

--========================================================================
-- FUNCTION  : Has_Worker_Completed    PUBLIC
-- PARAMETERS: p_request_id            IN  NUMBER  Unique identifier of a concurrent request.
-- RETURNS   : BOOLEAN
-- COMMENT   : This function accepts a unique identifier of concurrent request
--             and it returns boolean value. It returns TRUE if the corresponding worker
--             has completed, otherwise FALSE.
--=========================================================================
FUNCTION Has_worker_completed
( p_request_id IN NUMBER
)
RETURN BOOLEAN;


--========================================================================
-- PROCEDURE : Wait_For_Worker         PUBLIC
-- PARAMETERS: p_workers               IN  Required
--                                         Table (of type g_request_tbl_type) containing the
--                                         concurrent request IDs of all the active workers
--             x_worker_idx            OUT Index of the worker (within the p_workers table)
--                                         whose current task has completed and can start
--                                         a new concurrent request.
-- COMMENT   : This procedure polls submitted workers and suspend
--             the program till the completion of one of them; it returns
--             the completed worker through x_worker_idx
--=========================================================================
PROCEDURE Wait_for_worker
( p_workers    IN  g_request_tbl_type
, x_worker_idx OUT NOCOPY BINARY_INTEGER
);


--========================================================================
-- PROCEDURE : Wait_For_All_Workers    PUBLIC
-- PARAMETERS: p_workers               IN  Required
--                                         Table (of type g_request_tbl_type) containing the
--                                         concurrent request IDs of all the active workers
-- COMMENT   : This procedure polls submitted workers and suspend
--             the program till completion of all of workers.
--=========================================================================
PROCEDURE wait_for_all_workers
( p_workers IN g_request_tbl_type
);

END JMF_SHIKYU_UTIL;

 

/
