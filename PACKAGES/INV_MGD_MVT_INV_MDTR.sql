--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_INV_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_INV_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVIMDRS.pls 120.0 2005/05/25 04:32:26 appldev noship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVIMDRS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_INV_MDTR                                     |
--|     Inventory Transaction Mediator                                    |
--|     Get_INV_Transactions                                              |
--|     Get_INV_Details                                                   |
--|     Update_INV_Transactions                                           |
--| HISTORY                                                               |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Get_INV_Transactions    PRIVATE
-- PARAMETERS: inv_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for INV and returns the cursor.
--========================================================================

PROCEDURE Get_INV_Transactions
( inv_crsr               IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.invCurTyp
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Update_INV_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_INV_Transactions
( p_movement_transaction
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_INV_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for INV
--========================================================================

PROCEDURE Get_INV_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

END INV_MGD_MVT_INV_MDTR;

 

/
