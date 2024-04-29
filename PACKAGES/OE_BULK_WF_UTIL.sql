--------------------------------------------------------
--  DDL for Package OE_BULK_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_WF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEBUOWFS.pls 120.0.12010000.2 2008/11/18 12:39:39 smusanna ship $ */

-------------------------------------------------------------------
-- GLOBAL DECLARATIONS
-------------------------------------------------------------------

-- Global Table to store Order Type WF Assignments
TYPE ORDER_TYPE_WF_ASSIGN_REC IS RECORD (Order_Type_ID NUMBER,
                                   Process_Name VARCHAR2(30));

TYPE ORDER_TYPE_WF_ASSIGN_TBL IS TABLE OF ORDER_TYPE_WF_ASSIGN_REC
INDEX BY BINARY_INTEGER;

G_ORDER_TYPE_WF_ASSIGN_TBL       ORDER_TYPE_WF_ASSIGN_TBL;

-- Global Table to store Line Type WF Assignments
TYPE LINE_TYPE_WF_ASSIGN_REC IS RECORD (Order_Type_ID NUMBER,
                                   Line_Type_ID NUMBER,
                                   WF_Item_Type VARCHAR2(30),
                                   Process_Name VARCHAR2(30));

TYPE LINE_TYPE_WF_ASSIGN_TBL IS TABLE OF LINE_TYPE_WF_ASSIGN_REC
INDEX BY BINARY_INTEGER;

G_LINE_TYPE_WF_ASSIGN_TBL        LINE_TYPE_WF_ASSIGN_TBL;

G_HEADER_INDEX                   NUMBER;
G_LINE_INDEX                     NUMBER;


-------------------------------------------------------------------
-- FUNCTION/PROCEDURE DECLARATIONS
-------------------------------------------------------------------

-----------------------------------------------------------------------
-- FUNCTION Validate_OT_WF_Assignment
--
-- This function returns TRUE if this order type has a valid header WF
-- assignment.
--
-- If valid, it also returns the header WF process name in
-- x_process_name OUT parameter.
-----------------------------------------------------------------------

FUNCTION Validate_OT_WF_Assignment
  ( p_order_type_id         IN  NUMBER
   ,x_process_name          OUT NOCOPY VARCHAR2
  )
RETURN BOOLEAN;

-----------------------------------------------------------------------
-- FUNCTION Validate_LT_WF_Assignment
--
-- This function returns TRUE if order type, line type, WF item type
-- combination has a valid line WF assignment. p_item_type_code and
-- p_order_quantity_uom are used to derive the WF item type.
--
-- If valid, it also returns the line WF process name in x_process_name
-- OUT parameter.
-----------------------------------------------------------------------

FUNCTION Validate_LT_WF_Assignment
  ( p_order_type_id       IN NUMBER
  , p_line_index          IN NUMBER
  , p_line_rec            IN  OE_WSH_BULK_GRP.LINE_REC_TYPE
  , x_process_name OUT NOCOPY VARCHAR2

  )
RETURN BOOLEAN;

-----------------------------------------------------------------------
-- PROCEDURE Start_Flows
--
-- This API is called from BULK process order to start workflows for
-- all orders or lines processed in a batch.
-----------------------------------------------------------------------

PROCEDURE Start_Flows
  (p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
  ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
  ,x_return_status       OUT NOCOPY VARCHAR2
  );

END OE_BULK_WF_UTIL;

/
