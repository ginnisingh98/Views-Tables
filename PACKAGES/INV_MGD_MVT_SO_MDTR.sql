--------------------------------------------------------
--  DDL for Package INV_MGD_MVT_SO_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_MVT_SO_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVSMDRS.pls 120.0.12010000.1 2008/07/24 01:47:09 appldev ship $ */
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    INVSMDRS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Spec. of INV_MGD_MVT_SO_MDTR                                      |
--|     Get_SO_Transactions                                               |
--|     Get_TwoLeOneCntry_Txns                                            |
--|     Get_Triangulation_Txns                                            |
--|     Update_SO_Transaction                                             |
--|     Update_KIT_SO_Transaction                                         |
--|     Get_SO_Details                                                    |
--|     Get_IO_Details                                                    |
--|     Get_KIT_Status                                                    |
--|     Get_KIT_Triangulation_Status                                      |
--|     Get_KIT_SO_Details                                                |
--|                                                                       |
--| HISTORY                                                               |
--+======================================================================*/


--========================================================================
-- PROCEDURE : Get_SO_Transactions    PRIVATE
-- PARAMETERS: so_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for SO and returns the cursor.
--========================================================================

PROCEDURE Get_SO_Transactions
( so_crsr                IN  OUT NOCOPY  INV_MGD_MVT_DATA_STR.soCurTyp
, p_movement_transaction IN  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_TwoLeOneCntry_Txns    PRIVATE
-- PARAMETERS: so_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for SO and returns the cursor.
--========================================================================

PROCEDURE Get_TwoLeOneCntry_Txns
( sot_crsr               IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.soCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Get_Triangulation_Txns    PRIVATE
-- PARAMETERS: so_crsr                REF cursor
--             x_return_status         return status
--             p_start_date            Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for SO and returns the cursor.
--========================================================================

PROCEDURE Get_Triangulation_Txns
( sot_crsr               IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.soCurTyp
, p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_start_date           IN  DATE
, p_end_date             IN  DATE
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Update_SO_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_SO_Transactions
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_status               IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Update_KIT_SO_Transactions    PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Update the status of the transaction record to PROCESSED
--========================================================================

PROCEDURE Update_KIT_SO_Transactions
( p_movement_id          IN  NUMBER
, p_delivery_detail_id   IN  NUMBER
, p_link_to_line_id      IN  NUMBER
, p_status               IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Get_SO_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for SO
--========================================================================

PROCEDURE Get_SO_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_KIT_SO_Details      PRIVATE
-- PARAMETERS: x_movement_transaction  movement transaction record
--             p_link_to_line_id       parent line id
-- COMMENT   : Get all the additional data required for KIT SO
--========================================================================
PROCEDURE Get_KIT_SO_Details
( p_link_to_line_id      IN VARCHAR2
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
);

--========================================================================
-- PROCEDURE : Get_IO_Details         PRIVATE
-- PARAMETERS: x_return_status         return status
--             p_movement_transaction  movement transaction record
-- COMMENT   : Get all the additional data required for IO
--========================================================================

PROCEDURE Get_IO_Details
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
);

--========================================================================
-- FUNCTION  : Get_KIT_Status
-- PARAMETERS: p_delivery_detail_id         delivery detail id
-- COMMENT   : Function that returns the status of a movement kit record.
--             if a movement record for kit has been created, the status
--             returned is 'Y', otherwise return 'N'
--=========================================================================

FUNCTION Get_KIT_Status
( p_delivery_detail_id IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION  : Get_KIT_Triangulation_Status
-- PARAMETERS: p_delivery_detail_id         delivery detail id
-- COMMENT   : Function that returns the status of a movement kit record.
--             if a movement record for kit has been created, the status
--             returned is 'Y', otherwise return 'N'
--=========================================================================

FUNCTION Get_KIT_Triangulation_Status
( p_delivery_detail_id IN NUMBER
)
RETURN VARCHAR2;

END INV_MGD_MVT_SO_MDTR;

/
